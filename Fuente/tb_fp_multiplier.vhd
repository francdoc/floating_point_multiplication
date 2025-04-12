library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_fp_multiplier is
end tb_fp_multiplier;

architecture behavior of tb_fp_multiplier is

  component fp_multiplier is
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;   -- Now includes reset.
      A      : in  std_logic_vector(31 downto 0);
      B      : in  std_logic_vector(31 downto 0);
      result : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Signal declarations.
  signal clk    : std_logic := '0';
  signal rst    : std_logic := '1';  -- Start with reset high.
  signal A, B   : std_logic_vector(31 downto 0) := (others => '0');
  signal result : std_logic_vector(31 downto 0);

  -- Custom function to convert a 32-bit std_logic_vector to an 8-digit hexadecimal string.
  function to_hex(slv: std_logic_vector) return string is
    constant hex_chars: string := "0123456789ABCDEF";
    variable result_str: string(1 to 8);
    variable nibble: unsigned(3 downto 0);
  begin
    for i in 0 to 7 loop
      nibble := unsigned(slv((31 - 4*i) downto (28 - 4*i)));
      result_str(i+1) := hex_chars(to_integer(nibble) + 1);
    end loop;
    return result_str;
  end function;

begin

  -- Clock generator: period = 20 ns (10 ns high, 10 ns low).
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for 10 ns;
      clk <= '1';
      wait for 10 ns;
    end loop;
  end process;

  -- Instantiate the DUT.
  DUT: fp_multiplier
    port map (
      clk    => clk,
      rst    => rst,
      A      => A,
      B      => B,
      result => result
    );

  -- Stimulus process.
  stim_proc: process
  begin
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait for 10 ns;  -- Let the first rising edge occur after reset is deasserted.

    A <= x"40A00000";  -- 5.0 in IEEE754 single precision
    B <= x"40400000";  -- 3.0 in IEEE754 single precision

    wait for 40 ns;
    
    report "Test #1: 5.0 * 3.0 = 0x" & to_hex(result) severity note;
    wait;  -- Infinite wait to keep simulation running.
  end process;

end behavior;
