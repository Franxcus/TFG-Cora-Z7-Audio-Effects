library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_transmitter is
    port (
        clk       : in std_logic;
        tx_tick   : in std_logic;
        bit_index : in integer range 0 to 63;
        left_sample  : in signed(23 downto 0);
        right_sample : in signed(23 downto 0);
        dac_din : out std_logic
    );
end i2s_transmitter;

architecture Behavioral of i2s_transmitter is
    signal left_latched  : signed(23 downto 0) := (others => '0');
    signal right_latched : signed(23 downto 0) := (others => '0');
    signal dac_din_reg : std_logic := '0';
begin
    process(clk)
        variable sample_position : integer range 0 to 23;
    begin
        if rising_edge(clk) then
            if tx_tick = '1' then
                if bit_index = 0 then
                    left_latched <= left_sample;
                    right_latched <= right_sample;
                    dac_din_reg <= '0';
                elsif bit_index >= 1 and bit_index <= 24 then
                    sample_position := 24 - bit_index;
                    dac_din_reg <= left_latched(sample_position);
                elsif bit_index >= 33 and bit_index <= 56 then
                    sample_position := 56 - bit_index;
                    dac_din_reg <= right_latched(sample_position);
                else
                    dac_din_reg <= '0';
                end if;
            end if;
        end if;
    end process;
    dac_din <= dac_din_reg;
end Behavioral;
