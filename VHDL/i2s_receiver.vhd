library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_receiver is
    port (
        clk       : in std_logic;
        rx_tick   : in std_logic;
        bit_index : in integer range 0 to 63;
        adc_dout : in std_logic;
        left_sample  : out signed(23 downto 0);
        right_sample : out signed(23 downto 0);
        sample_valid : out std_logic
    );
end i2s_receiver;

architecture Behavioral of i2s_receiver is
    signal left_shift  : signed(23 downto 0) := (others => '0');
    signal right_shift : signed(23 downto 0) := (others => '0');
    signal left_sample_reg  : signed(23 downto 0) := (others => '0');
    signal right_sample_reg : signed(23 downto 0) := (others => '0');
    signal sample_valid_reg : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            sample_valid_reg <= '0';
            if rx_tick = '1' then
                if bit_index >= 1 and bit_index <= 24 then
                    left_shift <= left_shift(22 downto 0) & adc_dout;
                elsif bit_index >= 33 and bit_index <= 56 then
                    right_shift <= right_shift(22 downto 0) & adc_dout;
                    if bit_index = 56 then
                        left_sample_reg <= left_shift;
                        right_sample_reg <= right_shift(22 downto 0) & adc_dout;
                        sample_valid_reg <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    left_sample <= left_sample_reg;
    right_sample <= right_sample_reg;
    sample_valid <= sample_valid_reg;
end Behavioral;
