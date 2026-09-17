library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity flanger_effect is
    port (
        clk          : in  std_logic;
        sample_valid : in  std_logic;
        left_in      : in  signed(23 downto 0);
        right_in     : in  signed(23 downto 0);
        left_out     : out signed(23 downto 0);
        right_out    : out signed(23 downto 0)
    );
end flanger_effect;

architecture Behavioral of flanger_effect is
    subtype sample_t is signed(23 downto 0);
    constant RAM_DEPTH : integer := 512;
    constant MIN_DELAY : integer := 24;
    constant MAX_DELAY : integer := 192;
    constant LFO_DIV   : integer := 160;

    type ram_t is array (0 to RAM_DEPTH - 1) of sample_t;
    signal ram_l, ram_r : ram_t := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of ram_l : signal is "block";
    attribute ram_style of ram_r : signal is "block";

    signal rd_addr, wr_addr, wr_ptr : integer range 0 to RAM_DEPTH - 1 := 0;
    signal rd_l, rd_r, wr_l, wr_r : sample_t := (others => '0');
    signal wr_en : std_logic := '0';
    signal in_l_reg, in_r_reg, out_l_reg, out_r_reg : sample_t := (others => '0');

    signal current_delay : integer range MIN_DELAY to MAX_DELAY := MIN_DELAY;
    signal lfo_counter : integer range 0 to LFO_DIV - 1 := 0;
    signal lfo_up : std_logic := '1';

    type state_t is (IDLE, WAIT_READ, PROCESS_SAMPLE);
    signal state : state_t := IDLE;

    function circ(p, d : integer) return integer is
    begin
        if p >= d then return p - d; else return RAM_DEPTH + p - d; end if;
    end function;

    function sat24(v : signed(26 downto 0)) return sample_t is
        variable r : sample_t;
    begin
        if v > to_signed(8388607, 27) then r := to_signed(8388607, 24);
        elsif v < to_signed(-8388608, 27) then r := to_signed(-8388608, 24);
        else r := resize(v, 24);
        end if;
        return r;
    end function;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            rd_l <= ram_l(rd_addr);
            rd_r <= ram_r(rd_addr);
            if wr_en = '1' then
                ram_l(wr_addr) <= wr_l;
                ram_r(wr_addr) <= wr_r;
            end if;
        end if;
    end process;

    process(clk)
        variable mem_l, mem_r, mix_l, mix_r : signed(26 downto 0);
    begin
        if rising_edge(clk) then
            wr_en <= '0';
            case state is
                when IDLE =>
                    if sample_valid = '1' then
                        in_l_reg <= left_in;
                        in_r_reg <= right_in;
                        rd_addr <= circ(wr_ptr, current_delay);
                        state <= WAIT_READ;
                    end if;

                when WAIT_READ =>
                    state <= PROCESS_SAMPLE;

                when PROCESS_SAMPLE =>
                    mem_l := resize(in_l_reg, 27) + resize(shift_right(rd_l, 1), 27);
                    mem_r := resize(in_r_reg, 27) + resize(shift_right(rd_r, 1), 27);
                    wr_l <= sat24(mem_l);
                    wr_r <= sat24(mem_r);

                    mix_l := resize(shift_right(in_l_reg, 1), 27) + resize(shift_right(rd_l, 1), 27);
                    mix_r := resize(shift_right(in_r_reg, 1), 27) + resize(shift_right(rd_r, 1), 27);
                    out_l_reg <= sat24(mix_l);
                    out_r_reg <= sat24(mix_r);

                    wr_addr <= wr_ptr;
                    wr_en <= '1';
                    if wr_ptr = RAM_DEPTH - 1 then wr_ptr <= 0; else wr_ptr <= wr_ptr + 1; end if;

                    if lfo_counter = LFO_DIV - 1 then
                        lfo_counter <= 0;
                        if lfo_up = '1' then
                            if current_delay = MAX_DELAY then current_delay <= current_delay - 1; lfo_up <= '0';
                            else current_delay <= current_delay + 1; end if;
                        else
                            if current_delay = MIN_DELAY then current_delay <= current_delay + 1; lfo_up <= '1';
                            else current_delay <= current_delay - 1; end if;
                        end if;
                    else
                        lfo_counter <= lfo_counter + 1;
                    end if;
                    state <= IDLE;
            end case;
        end if;
    end process;

    left_out <= out_l_reg;
    right_out <= out_r_reg;
end Behavioral;
