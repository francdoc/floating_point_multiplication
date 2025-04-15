library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Testbench para el multiplicador de punto flotante.
entity tb_fp_multiplier is
end tb_fp_multiplier;

architecture behavior of tb_fp_multiplier is

  -- Se declara el componente fp_multiplier, que realiza la multiplicación IEEE‑754.
  component fp_multiplier is
    port (
      clk    : in  std_logic;           -- Señal de reloj para sincronizar la operación.
      rst    : in  std_logic;           -- Señal de reinicio que limpia la salida cuando está activa.
      A      : in  std_logic_vector(31 downto 0);  -- Operando de entrada A en formato IEEE‑754.
      B      : in  std_logic_vector(31 downto 0);  -- Operando de entrada B en formato IEEE‑754.
      result : out std_logic_vector(31 downto 0)   -- Resultado de la multiplicación en formato IEEE‑754.
    );
  end component;

  -- Declaración de señales utilizadas en el testbench.
  signal clk    : std_logic := '0';               -- Señal de reloj.
  signal rst    : std_logic := '1';               -- Señal de reset iniciada en '1'.
  signal A, B   : std_logic_vector(31 downto 0) := (others => '0');  -- Operandos inicializados en 0.
  signal result : std_logic_vector(31 downto 0);  -- Resultado de la operación.

  -- Función personalizada para convertir un vector de 32 bits a hexadecimal.
  function to_hex(slv: std_logic_vector) return string is
    constant hex_chars: string := "0123456789ABCDEF";   -- Caracteres hexadecimales.
    variable result_str: string(1 to 8);                -- Cadena resultado de 8 caracteres.
    variable nibble: unsigned(3 downto 0);              -- Variable temporal para cada nibble (4 bits).
  begin
    for i in 0 to 7 loop
      nibble := unsigned(slv((31 - 4*i) downto (28 - 4*i)));  -- Extrae cada nibble.
      result_str(i+1) := hex_chars(to_integer(nibble) + 1);     -- Convierte el nibble a su correspondiente carácter hexadecimal.
    end loop;
    return result_str;
  end function;

begin

  -- Generador de reloj: período de 20 ns (10 ns en alto y 10 ns en bajo).
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    end loop;
  end process;

  -- Instanciación del dispositivo bajo prueba (DUT): fp_multiplier.
  DUT: fp_multiplier
    port map (
      clk    => clk,      -- Conecta la señal de reloj.
      rst    => rst,      -- Conecta la señal de reinicio.
      A      => A,        -- Conecta el operando A.
      B      => B,        -- Conecta el operando B.
      result => result    -- Conecta la salida del resultado.
    );

  -- Proceso de estímulo: se aplican múltiples casos de prueba.
  stim_proc: process
  begin
    -- Inicialmente se activa el reset para limpiar la salida.
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 10 ns;  -- Se espera a que se produzca el primer flanco de subida después de quitar el reset.
    
    ----------------------------------------------------------------------------
    -- Test #1: Multiplicar 5.0 por 3.0 = 15.0
    -- 5.0 en IEEE‑754 es 0x40A00000 y 3.0 es 0x40400000.
    -- Se espera que el resultado sea 0x41700000 (15.0).
    ----------------------------------------------------------------------------
    A <= x"40A00000";  
    B <= x"40400000";  
    wait for 40 ns;    
    report "Test #1: 5.0 * 3.0 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #2: Multiplicar -2.0 por 4.0 = -8.0
    -- -2.0 se representa como 0xC0000000 y 4.0 como 0x40800000.
    -- Se espera un resultado de 0xC1000000 (-8.0).
    ----------------------------------------------------------------------------
    A <= x"C0000000";  
    B <= x"40800000";
    wait for 40 ns;
    report "Test #2: -2.0 * 4.0 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #3: Multiplicar 1.5 por 2.0 = 3.0
    -- 1.5 se representa como 0x3FC00000 y 2.0 como 0x40000000.
    -- Se espera un resultado de 0x40400000 (3.0).
    ----------------------------------------------------------------------------
    A <= x"3FC00000";  
    B <= x"40000000";  
    wait for 40 ns;
    report "Test #3: 1.5 * 2.0 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #4: Multiplicar 0.5 por 0.5 = 0.25
    -- 0.5 se representa como 0x3F000000.
    -- Se espera un resultado de 0x3E800000 (0.25).
    ----------------------------------------------------------------------------
    A <= x"3F000000";  
    B <= x"3F000000";  
    wait for 40 ns;
    report "Test #4: 0.5 * 0.5 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #5: Multiplicar -1.0 por -1.0 = 1.0
    -- -1.0 se representa como 0xBF800000.
    -- Se espera un resultado de 0x3F800000 (1.0).
    ----------------------------------------------------------------------------
    A <= x"BF800000";  
    B <= x"BF800000";  
    wait for 40 ns;
    report "Test #5: -1.0 * -1.0 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #6: Multiplicar 10.0 por 10.0 = 100.0
    -- 10.0 se representa como 0x41200000.
    -- Se espera un resultado de 0x42C80000 (100.0).
    ----------------------------------------------------------------------------
    A <= x"41200000";  
    B <= x"41200000";  
    wait for 40 ns;
    report "Test #6: 10.0 * 10.0 = 0x" & to_hex(result) severity note;

    ----------------------------------------------------------------------------
    -- Test #7: Multiplicar 1.0 por -0.25 = -0.25
    -- 1.0 se representa como 0x3F800000 y -0.25 como 0xBE800000.
    -- Se espera un resultado de 0xBE800000 (-0.25).
    ----------------------------------------------------------------------------
    A <= x"3F800000";  
    B <= x"BE800000";  
    wait for 40 ns;
    report "Test #7: 1.0 * -0.25 = 0x" & to_hex(result) severity note;

    wait;  -- Fin de la simulación
  end process;

end behavior;