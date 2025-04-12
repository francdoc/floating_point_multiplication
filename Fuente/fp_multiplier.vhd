library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_multiplier is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;  -- Added reset input
    A      : in  std_logic_vector(31 downto 0);
    B      : in  std_logic_vector(31 downto 0);
    result : out std_logic_vector(31 downto 0)
  );
end fp_multiplier;

architecture behavior of fp_multiplier is
begin
  process(clk, rst)
    -- Local variables used only in this clocked process.
    variable sign_A, sign_B, sign_res : std_logic;
    variable exp_A, exp_B             : unsigned(7 downto 0);
    variable mant_A, mant_B           : std_logic_vector(22 downto 0);
    variable mant_A_ext, mant_B_ext   : unsigned(23 downto 0);
    variable product_mant             : unsigned(47 downto 0);
    variable product_mant_norm        : unsigned(22 downto 0);
    variable exp_temp                 : unsigned(8 downto 0);
    variable exp_res                  : unsigned(7 downto 0);
    variable res_temp                 : std_logic_vector(31 downto 0);
  begin
    if rst = '1' then
      result <= (others => '0');
    elsif rising_edge(clk) then
      -- 1. Decode the input floating-point number components.
      sign_A := A(31);
      sign_B := B(31);
      exp_A  := unsigned(A(30 downto 23));
      exp_B  := unsigned(B(30 downto 23));
      mant_A := A(22 downto 0);
      mant_B := B(22 downto 0);

      -- 2. Align mantissas by prepending the implicit "1" for normalized numbers.
      mant_A_ext := "1" & unsigned(mant_A);
      mant_B_ext := "1" & unsigned(mant_B);

      -- 3. Calculate the result sign (XOR of input signs).
      sign_res := sign_A xor sign_B;

      -- 4. Compute the exponent: (exp_A + exp_B - bias) where bias is 127.
      exp_temp := ('0' & exp_A) + ('0' & exp_B) - to_unsigned(127, 9);

      -- 5. Multiply the aligned mantissas (both are now 24 bits, result 48 bits).
      product_mant := mant_A_ext * mant_B_ext;

      -- 6. Normalize the product mantissa.
      if product_mant(47) = '1' then
        product_mant_norm := product_mant(46 downto 24);
        exp_res := exp_temp + 1;
      else
        product_mant_norm := product_mant(45 downto 23);
        exp_res := exp_temp(7 downto 0);
      end if;

      -- 7. Pack the sign, exponent, and mantissa into the 32-bit result.
      res_temp := sign_res 
                  & std_logic_vector(exp_res) 
                  & std_logic_vector(product_mant_norm);
      result <= res_temp;
    end if;
  end process;
end behavior;
