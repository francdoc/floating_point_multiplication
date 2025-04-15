library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Bit index (de izquierda a derecha) 31 a 0.
-- Estructura de 32 bits IEEE 754 single-precision.
--  ┌───┬────────────────┬─────────────────────────────────────────────┐
--  │ S │   Exponente    │                  Mantisa                    │
--  └───┴────────────────┴─────────────────────────────────────────────┘
--  1 bit    8 bits                        23 bits

-- En el formato IEEE‑754 de precisión simple (32 bits), un número normalizado se representa de la siguiente manera:
--    Valor = (−1)^(S)x2^(E−bias)×(1.f)
--    donde:
--          S es el bit de signo.
--          E es el exponente almacenado en 8 bits.
--          bias es el sesgo, que para precisión simple es 127.
--          f es la fracción (mantisa) de 23 bits, que representa la parte fraccionaria del número.
--          En números normalizados, el valor real de la mantisa es 1.f. El dígito entero “1” (el 1 implícito) no se almacena porque siempre es 1.

-- Aclaración:
-- Se utiliza la biblioteca oficial aritmética (IEEE.numeric_std) en este diseño.
-- Esto permite emplear operadores y funciones aritméticas (como "+" y "*") en lugar de implementar manualmente sumadores, multiplicadores u otros bloques aritméticos.

entity fp_multiplier is
  port (
    clk    : in  std_logic; -- Señal de reloj (clock) que sincroniza la operación del multiplicador. Cada flanco de subida de este reloj activará el proceso que realiza la multiplicación.
    rst    : in  std_logic; -- Señal de reinicio (reset), que se utiliza para inicializar o limpiar la salida cuando es necesario.
    A      : in  std_logic_vector(31 downto 0); -- Operando de entrada para la multiplicación. Este vector de 32 bits representa un número IEEE-754 (punto flotante de simple precisión).
    B      : in  std_logic_vector(31 downto 0); -- Operando de entrada para la multiplicación. Este vector de 32 bits representa un número IEEE-754 (punto flotante de simple precisión).
    result : out std_logic_vector(31 downto 0) -- Salida del multiplicador. Este vector de 32 bits contendrá el producto de A y B en el mismo formato IEEE-754 (número de punto flotante en simple precisión).
  );
end fp_multiplier;

architecture behavior of fp_multiplier is
begin
  process(clk, rst)
  -- Variables locales que se utilizan dentro del proceso, las cuales se actualizan en cada ciclo de reloj para realizar todas las operaciones necesarias en la multiplicación de dos números en coma flotante IEEE‑754 de 32 bits.
    
    -- sign_A y sign_B se utilizan para almacenar el bit de signo (bit 31; bits numerados del 0 al 31) de cada uno de los operandos de entrada A y B.
    -- sign_res se utiliza para almacenar el bit de signo del resultado (bit 32; bits numerados del 0 al 31).
    variable sign_A, sign_B, sign_res : std_logic; 

    -- exp_A y exp_B se utilizan para extraer el exponente de cada operando (bits 30 a 23), donde la conversión a tipo unsigned sirve más adelante para llevar a cabo operaciones aritméticas (como la suma y la resta del sesgo).
    -- exp_A y exp_B cuentan cada uno con un sesgo de 127 según el estándar IEEE‑754. Cuando se los suma, el resultado potencial puede requerir hasta 9 bits (ej: exp_A + exp_B = 510 -> 111111110).
    variable exp_A, exp_B             : unsigned(7 downto 0);

    -- mant_A y mant_B se utilizan para almacenar los 23 bits de la mantisa (parte fraccionaria) de cada entrada (bits 22 a 0). En números normalizados, la mantisa real es 1.mantisa, pero el “1” implícito no se almacena en estas 2 variables.
    variable mant_A, mant_B           : std_logic_vector(22 downto 0);

    --  mant_A_ext y mant_B_ext se utilizan para reconstruir la mantisa completa de 24 bits (bits 23 a 0) añadiendo el bit '1' ignorado por las variables mant_A y mant_B.
    variable mant_A_ext, mant_B_ext   : unsigned(23 downto 0);

    -- product_mant se utiliza para almacenar el producto de las mantisas. Al multiplicar dos números de 24 bits, este producto puede ocupar hasta 48 bits.
    variable product_mant             : unsigned(47 downto 0);

    -- product_mant_norm se utiliza para almacenar la mantisa normalizada (bits 22 a 0).
    variable product_mant_norm        : unsigned(22 downto 0);

    -- exp_temp se utiliza para almacenar una variable de exponente temporal, la cual consiste en quitar el sesgo de los dos operandos y luego se vuelve a añadir un único sesgo para el resultado -> exp_temp = (exp_A−127) + (exp_B−127) + 127 = exp_A + exp_B − 127
    -- exp_temp se la extiende a 9 bits para evitar cualquier overflow durante la suma de los exponentes.
    variable exp_temp                 : unsigned(8 downto 0);
    
    -- exp_res se utiliza para guardar el valor final del exponente en 8 bits que se utilizará para empaquetar el resultado.
    -- exp_res se la deriva a partir de exp_temp y en función de la normalización del producto. 
    -- exp_res puede incrementarse si el producto de mantisas se desplaza, es decir, si el bit 47 es ‘1’.
    variable exp_res                  : unsigned(7 downto 0);

    --res_temp es el vector resultante de 32 bits que corresponde a la representación IEEE-754 final del producto de A y B.
    variable res_temp                 : std_logic_vector(31 downto 0);
  begin
    -- Se revisa si la señal de reset (rst) está activada, si lo está entonces todos los bits del vector de 32 bits que forma result valen '0'.
    -- Al forzar el resultado a cero se garantiza que el sistema empieza en un estado conocido y seguro al haber un reset. Hasta que no se desactive el reset, el sistema no procesa datos y siempre da un resultado de salida cero.
    if rst = '1' then
      result <= (others => '0');

    -- Se activa la operación del multiplicador de forma sincronada con el clock, sólo se ejecuta el código del proceso en cada flanco ascendente.
    elsif rising_edge(clk) then
      -- -- Se extraen el bit de signo (bit 31), los 8 bits del exponente (bits 30 downto 23) y los 23 bits de la mantisa (bits 22 downto 0) del número en formato IEEE‑754.
      sign_A := A(31);
      sign_B := B(31);
      exp_A  := unsigned(A(30 downto 23));
      exp_B  := unsigned(B(30 downto 23));
      mant_A := A(22 downto 0);
      mant_B := B(22 downto 0);

      -- Se convierten mant_A y mant_B a tipo unsigned para permitir operaciones aritméticas.
      -- Se antepone el '1' implícito (que no se almacena en el formato IEEE-754) para formar el significando completo de 24 bits tanto para mant_A_ext como para mant_B_ext.
      -- Este procedimiento asume que A y B son números normalizados. Es decir, que su campo de exponente no es cero.
      mant_A_ext := "1" & unsigned(mant_A);
      mant_B_ext := "1" & unsigned(mant_B);

      -- Se calcula el signo del resultado (operación XOR de los signos de las entradas).
      sign_res := sign_A xor sign_B;

      -- Se calcula el exponente: (exp_A + exp_B - bias) donde bias es 127. 
      -- Se extiende a 9 bits (concatenando un '0' al inicio) para evitar cualquier overflow durante la suma de los exponentes.
      exp_temp := ('0' & exp_A) + ('0' & exp_B) - to_unsigned(127, 9);

      -- Se multiplican las mantisas extendidas (con el "1" implícito añadido), resultando en un valor de 48 bits almacenado en product_mant.
      product_mant := mant_A_ext * mant_B_ext;

      -- Si cada número individual (está en el rango [1,2): el número resultante se escribe como 1.xxx (en binario), por lo que el bit más significativo (el bit 47 del producto de 48 bits) será 0.
      -- Si cada número individual está en el rango [2,4): el número resultante se expresa en binario como 10.xxx, lo cual implica que el bit 47 es 1.

      -- Esta posibilidad se ejecuta si el bit 47 del producto (product_mant(47)) es '1'.
      if product_mant(47) = '1' then
        -- Se descarta entonces el bit 47 (ya que el "1" implícito se reconstruirá) y se seleccionan los bits 46 hasta 24 para formar la mantisa final (23 bits) acorde al estándar IEEE‑754 de precisión simple (32 bits).
        -- Al seleccionar los bits de 46 a 24 de la señal product_mant, se está realizando un desplazamiento a la derecha de una posición. Lo cual equivale a dividir el valor (el significando del producto) por 2.
        product_mant_norm := product_mant(46 downto 24);
        -- Al desplazar el producto a la derecha (equivalente a dividir entre 2), el valor del significando disminuye en un factor de 2. 
        -- Para mantener el valor global del número igual, se debe compensar aumentando el exponente en 1.
        exp_res := exp_temp + 1;
      
      else
      -- Esta posibilidad se ejecuta si el bit 47 del producto (product_mant(47)) es '0'.
      -- Entonces se toman directamente los bits 45 a 23 para formar la mantisa final acorde al estándar IEEE‑754 de precisión simple (32 bits).
        product_mant_norm := product_mant(45 downto 23);
        exp_res := exp_temp(7 downto 0);
      end if;

      -- Empaqueta el bit de signo, el exponente y la mantisa normalizada en un vector de 32 bits,
      -- según el formato IEEE‑754, y asigna ese vector a la salida 'result'.      r
      res_temp := sign_res 
                  & std_logic_vector(exp_res) 
                  & std_logic_vector(product_mant_norm);
      result <= res_temp;
    end if;
  end process;
end behavior;