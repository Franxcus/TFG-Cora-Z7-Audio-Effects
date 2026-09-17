library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity effect_fsm is
    port (
        clk            : in  std_logic;
        effect_command : in  unsigned(2 downto 0);
        effect_select  : out unsigned(2 downto 0)
    );
end effect_fsm;

architecture Behavioral of effect_fsm is

    --------------------------------------------------------------------
    -- ESTADOS
    --
    -- 000: Audio limpio
    -- 001: Tremolo
    -- 010: Reverb
    -- 011: Chorus
    -- 100: Delay
    -- 101: Flanger
    --------------------------------------------------------------------

    type state_t is (
        S_CLEAN,
        S_TREMOLO,
        S_REVERB,
        S_CHORUS,
        S_DELAY,
        S_FLANGER
    );

    signal current_state : state_t := S_CLEAN;
    signal next_state    : state_t := S_CLEAN;

begin

    --------------------------------------------------------------------
    -- REGISTRO DE ESTADO
    --------------------------------------------------------------------

    process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    --------------------------------------------------------------------
    -- LOGICA DE TRANSICION
    --
    -- El estado solicitado procede del AXI GPIO.
    --------------------------------------------------------------------

    process(current_state, effect_command)
    begin

        next_state <= current_state;

        case effect_command is

            when "000" =>
                next_state <= S_CLEAN;

            when "001" =>
                next_state <= S_TREMOLO;

            when "010" =>
                next_state <= S_REVERB;

            when "011" =>
                next_state <= S_CHORUS;

            when "100" =>
                next_state <= S_DELAY;

            when "101" =>
                next_state <= S_FLANGER;

            when others =>
                next_state <= S_CLEAN;

        end case;

    end process;

    --------------------------------------------------------------------
    -- SALIDA MOORE
    --------------------------------------------------------------------

    process(current_state)
    begin

        case current_state is

            when S_CLEAN =>
                effect_select <= "000";

            when S_TREMOLO =>
                effect_select <= "001";

            when S_REVERB =>
                effect_select <= "010";

            when S_CHORUS =>
                effect_select <= "011";

            when S_DELAY =>
                effect_select <= "100";

            when S_FLANGER =>
                effect_select <= "101";

        end case;

    end process;

end Behavioral;
