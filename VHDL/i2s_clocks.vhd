library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2s_clocks is
    port (
        clk : in std_logic;
        bck  : out std_logic;
        lrck : out std_logic;
        rx_tick   : out std_logic;
        tx_tick   : out std_logic;
        bit_index : out integer range 0 to 63
    );
end i2s_clocks;

architecture Behavioral of i2s_clocks is
    constant HALF_BCK_DIVIDER : integer := 2;
    signal divider_counter : integer range 0 to HALF_BCK_DIVIDER - 1 := 0;
    signal bck_reg  : std_logic := '0';
    signal lrck_reg : std_logic := '0';
    signal rx_tick_reg : std_logic := '0';
    signal tx_tick_reg : std_logic := '0';
    signal bit_index_reg : integer range 0 to 63 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            rx_tick_reg <= '0';
            tx_tick_reg <= '0';
            if divider_counter = HALF_BCK_DIVIDER - 1 then
                divider_counter <= 0;
                if bck_reg = '0' then
                    bck_reg <= '1';
                    rx_tick_reg <= '1';
                else
                    bck_reg <= '0';
                    tx_tick_reg <= '1';
                    if bit_index_reg = 63 then
                        bit_index_reg <= 0;
                        lrck_reg <= '0';
                    else
                        bit_index_reg <= bit_index_reg + 1;
                        if bit_index_reg = 31 then
                            lrck_reg <= '1';
                        end if;
                    end if;
                end if;
            else
                divider_counter <= divider_counter + 1;
            end if;
        end if;
    end process;
    bck <= bck_reg;
    lrck <= lrck_reg;
    rx_tick <= rx_tick_reg;
    tx_tick <= tx_tick_reg;
    bit_index <= bit_index_reg;
end Behavioral;
