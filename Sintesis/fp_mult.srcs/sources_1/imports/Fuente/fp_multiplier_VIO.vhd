library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Wrapper VIO para el multiplicador de punto flotante fp_multiplier
entity fp_multiplier_VIO is
  port (
    clk_i : in std_logic -- Señal de reloj (clock) que sincroniza la operación del multiplicador
  );
end fp_multiplier_VIO;

architecture fp_multiplier_VIO_arch of fp_multiplier_VIO is

  -- Declaración del componente fp_multiplier
  component fp_multiplier is
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      A      : in  std_logic_vector(31 downto 0);
      B      : in  std_logic_vector(31 downto 0);
      result : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Componente VIO generado por IP
  COMPONENT vio_0
    PORT (
      clk : IN STD_LOGIC;
      probe_in0 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- result
      probe_out0 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- A
      probe_out1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- B
      probe_out2 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)  -- rst
    );
  END COMPONENT;

  -- Señales de conexión entre VIO y fp_multiplier
  signal vio_A   : std_logic_vector(31 downto 0);
  signal vio_B   : std_logic_vector(31 downto 0);
  signal vio_RST : std_logic_vector(0 downto 0);
  signal int_res : std_logic_vector(31 downto 0);

begin

  -- Instancia del multiplicador de punto flotante
  fp_multiplier_inst : fp_multiplier
    port map(
      clk    => clk_i,
      rst    => vio_RST(0),
      A      => vio_A,
      B      => vio_B,
      result => int_res
    );

  -- Instancia del bloque VIO para inyectar A, B, rst y monitorear result
  vio_inst : vio_0
    PORT MAP(
      clk        => clk_i,
      probe_in0  => int_res,
      probe_out0 => vio_A,
      probe_out1 => vio_B,
      probe_out2 => vio_RST
    );
end fp_multiplier_VIO_arch;
