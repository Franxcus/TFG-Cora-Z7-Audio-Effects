library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tremolo_effect is
    port (
        clk          : in  std_logic;
        sample_valid : in  std_logic;
        left_in      : in  signed(23 downto 0);
        right_in     : in  signed(23 downto 0);
        left_out     : out signed(23 downto 0);
        right_out    : out signed(23 downto 0)
    );
end tremolo_effect;

architecture Behavioral of tremolo_effect is
    constant MIN_GAIN : integer := 64;
    constant MAX_GAIN : integer := 256;
    constant LFO_DIV  : integer := 240;

    signal current_gain : integer range MIN_GAIN to MAX_GAIN := MAX_GAIN;
    signal lfo_counter  : integer range 0 to LFO_DIV - 1 := 0;
    signal lfo_up       : std_logic := '0';

    signal left_reg  : signed(23 downto 0) := (others => '0');
    signal right_reg : signed(23 downto 0) := (others => '0');
begin
    process(clk)
        variable gain_q8   : signed(8 downto 0);
        variable product_l : signed(32 downto 0);
        variable product_r : signed(32 downto 0);
    begin
        if rising_edge(clk) then
            if sample_valid = '1' then
                gain_q8 := to_signed(current_gain, 9);
                product_l := left_in * gain_q8;
                product_r := right_in * gain_q8;

                left_reg  <= resize(shift_right(product_l, 8), 24);
                right_reg <= resize(shift_right(product_r, 8), 24);

                if lfo_counter = LFO_DIV - 1 then
                    lfo_counter <= 0;
                    if lfo_up = '1' then
                        if current_gain = MAX_GAIN then
                            current_gain <= current_gain - 1;
                            lfo_up <= '0';
                        else
                            current_gain <= current_gain + 1;
                        end if;
                    else
                        if current_gain = MIN_GAIN then
                            current_gain <= current_gain + 1;
                            lfo_up <= '1';
                        else
                            current_gain <= current_gain - 1;
                        end if;
                    end if;
                else
                    lfo_counter <= lfo_counter + 1;
                end if;
            end if;
        end if;
    end process;

    left_out  <= left_reg;
    right_out <= right_reg;
end Behavioral;
