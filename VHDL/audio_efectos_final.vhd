library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity audio_efectos_final is
    port (
        ----------------------------------------------------------------
        -- RELOJ PRINCIPAL DE LA CORA Z7
        ----------------------------------------------------------------
        clk : in std_logic;

        ----------------------------------------------------------------
        -- CONTROL DEL EFECTO DESDE AXI GPIO
        --
        -- 000 = Audio limpio
        -- 001 = Tremolo
        -- 010 = Reverb
        -- 011 = Chorus
        -- 100 = Delay
        -- 101 = Flanger
        ----------------------------------------------------------------
        effect_command : in unsigned(2 downto 0);

        ----------------------------------------------------------------
        -- ADC PCM1808
        ----------------------------------------------------------------
        adc_sck  : out std_logic;
        adc_bck  : out std_logic;
        adc_lrck : out std_logic;
        adc_dout : in  std_logic;

        ----------------------------------------------------------------
        -- DAC PCM5102
        ----------------------------------------------------------------
        dac_bck  : out std_logic;
        dac_lrck : out std_logic;
        dac_din  : out std_logic;

        ----------------------------------------------------------------
        -- LED RGB
        ----------------------------------------------------------------
        led0_r : out std_logic;
        led0_g : out std_logic;
        led0_b : out std_logic
    );
end audio_efectos_final;


architecture Structural of audio_efectos_final is

    --------------------------------------------------------------------
    -- CLOCK WIZARD
    --
    -- clk_in1  = 125 MHz
    -- clk_out1 = 12,288 MHz
    --------------------------------------------------------------------

    component clk_wiz_0
        port (
            clk_out1 : out std_logic;
            reset    : in  std_logic;
            locked   : out std_logic;
            clk_in1  : in  std_logic
        );
    end component;

    signal audio_clk  : std_logic;
    signal clk_locked : std_logic;


    --------------------------------------------------------------------
    -- SEÑALES I2S
    --------------------------------------------------------------------

    signal i2s_bck  : std_logic;
    signal i2s_lrck : std_logic;
    signal rx_tick  : std_logic;
    signal tx_tick  : std_logic;

    signal bit_index : integer range 0 to 63 := 0;


    --------------------------------------------------------------------
    -- MUESTRAS DEL ADC
    --------------------------------------------------------------------

    signal adc_left  : signed(23 downto 0) := (others => '0');
    signal adc_right : signed(23 downto 0) := (others => '0');

    signal sample_valid : std_logic := '0';


    --------------------------------------------------------------------
    -- CONTROL DE EFECTOS
    --------------------------------------------------------------------

    signal effect_select : unsigned(2 downto 0) := "000";


    --------------------------------------------------------------------
    -- SALIDAS DE LOS CINCO EFECTOS
    --------------------------------------------------------------------

    signal tremolo_left, tremolo_right : signed(23 downto 0);
    signal reverb_left,  reverb_right  : signed(23 downto 0);
    signal chorus_left,  chorus_right  : signed(23 downto 0);
    signal delay_left,   delay_right   : signed(23 downto 0);
    signal flanger_left, flanger_right : signed(23 downto 0);


    --------------------------------------------------------------------
    -- SALIDA SELECCIONADA
    --------------------------------------------------------------------

    signal selected_left  : signed(23 downto 0) := (others => '0');
    signal selected_right : signed(23 downto 0) := (others => '0');


begin


    --------------------------------------------------------------------
    -- 1. GENERACIÓN DEL RELOJ DE AUDIO
    --------------------------------------------------------------------

    clock_generator : clk_wiz_0
        port map (
            clk_out1 => audio_clk,
            reset    => '0',
            locked   => clk_locked,
            clk_in1  => clk
        );


    --------------------------------------------------------------------
    -- 2. GENERACIÓN DE RELOJES I2S
    --------------------------------------------------------------------

    clocks_inst : entity work.i2s_clocks
        port map (
            clk       => audio_clk,
            bck       => i2s_bck,
            lrck      => i2s_lrck,
            rx_tick   => rx_tick,
            tx_tick   => tx_tick,
            bit_index => bit_index
        );

    adc_sck  <= audio_clk;
    adc_bck  <= i2s_bck;
    adc_lrck <= i2s_lrck;

    dac_bck  <= i2s_bck;
    dac_lrck <= i2s_lrck;


    --------------------------------------------------------------------
    -- 3. RECEPCIÓN DE AUDIO DESDE EL ADC
    --------------------------------------------------------------------

    receiver_inst : entity work.i2s_receiver
        port map (
            clk          => audio_clk,
            rx_tick      => rx_tick,
            bit_index    => bit_index,
            adc_dout     => adc_dout,
            left_sample  => adc_left,
            right_sample => adc_right,
            sample_valid => sample_valid
        );


    --------------------------------------------------------------------
    -- 4. FSM DE SELECCIÓN DE EFECTOS
    --
    -- La orden procede ahora del AXI GPIO conectado al
    -- Processing System del Zynq.
    --------------------------------------------------------------------

    fsm_inst : entity work.effect_fsm
        port map (
            clk            => audio_clk,
            effect_command => effect_command,
            effect_select  => effect_select
        );


    --------------------------------------------------------------------
    -- 5. INSTANCIAS INDEPENDIENTES DE LOS EFECTOS
    --------------------------------------------------------------------

    tremolo_inst : entity work.tremolo_effect
        port map (
            clk          => audio_clk,
            sample_valid => sample_valid,
            left_in      => adc_left,
            right_in     => adc_right,
            left_out     => tremolo_left,
            right_out    => tremolo_right
        );


    reverb_inst : entity work.reverb_effect
        port map (
            clk          => audio_clk,
            sample_valid => sample_valid,
            left_in      => adc_left,
            right_in     => adc_right,
            left_out     => reverb_left,
            right_out    => reverb_right
        );


    chorus_inst : entity work.chorus_effect
        port map (
            clk          => audio_clk,
            sample_valid => sample_valid,
            left_in      => adc_left,
            right_in     => adc_right,
            left_out     => chorus_left,
            right_out    => chorus_right
        );


    delay_inst : entity work.delay_effect
        port map (
            clk          => audio_clk,
            sample_valid => sample_valid,
            left_in      => adc_left,
            right_in     => adc_right,
            left_out     => delay_left,
            right_out    => delay_right
        );


    flanger_inst : entity work.flanger_effect
        port map (
            clk          => audio_clk,
            sample_valid => sample_valid,
            left_in      => adc_left,
            right_in     => adc_right,
            left_out     => flanger_left,
            right_out    => flanger_right
        );


    --------------------------------------------------------------------
    -- 6. MULTIPLEXOR DE SALIDA
    --
    -- 000 = Audio limpio
    -- 001 = Tremolo
    -- 010 = Reverb
    -- 011 = Chorus
    -- 100 = Delay
    -- 101 = Flanger
    --------------------------------------------------------------------

    process(
        effect_select,
        adc_left,
        adc_right,
        tremolo_left,
        tremolo_right,
        reverb_left,
        reverb_right,
        chorus_left,
        chorus_right,
        delay_left,
        delay_right,
        flanger_left,
        flanger_right
    )
    begin

        case effect_select is

            when "000" =>
                selected_left  <= adc_left;
                selected_right <= adc_right;

            when "001" =>
                selected_left  <= tremolo_left;
                selected_right <= tremolo_right;

            when "010" =>
                selected_left  <= reverb_left;
                selected_right <= reverb_right;

            when "011" =>
                selected_left  <= chorus_left;
                selected_right <= chorus_right;

            when "100" =>
                selected_left  <= delay_left;
                selected_right <= delay_right;

            when "101" =>
                selected_left  <= flanger_left;
                selected_right <= flanger_right;

            when others =>
                selected_left  <= adc_left;
                selected_right <= adc_right;

        end case;

    end process;


    --------------------------------------------------------------------
    -- 7. TRANSMISIÓN I2S HACIA EL DAC
    --------------------------------------------------------------------

    transmitter_inst : entity work.i2s_transmitter
        port map (
            clk          => audio_clk,
            tx_tick      => tx_tick,
            bit_index    => bit_index,
            left_sample  => selected_left,
            right_sample => selected_right,
            dac_din      => dac_din
        );


    --------------------------------------------------------------------
    -- 8. LED RGB
    --
    -- LED activo a nivel bajo:
    -- 0 = componente encendido
    -- 1 = componente apagado
    --
    -- 000 CLEAN   = Blanco
    -- 001 TREMOLO = Azul
    -- 010 REVERB  = Magenta
    -- 011 CHORUS  = Amarillo
    -- 100 DELAY   = Rojo
    -- 101 FLANGER = Verde
    --------------------------------------------------------------------

    process(effect_select)
    begin

        -- Por defecto: LED apagado
        led0_r <= '0';
        led0_g <= '0';
        led0_b <= '0';

        case effect_select is

            ------------------------------------------------------------
            -- AUDIO LIMPIO -> BLANCO
            -- R + G + B
            ------------------------------------------------------------
            when "000" =>
                led0_r <= '1';
                led0_g <= '1';
                led0_b <= '1';


            ------------------------------------------------------------
            -- TREMOLO -> AZUL
            ------------------------------------------------------------
            when "001" =>
                led0_r <= '0';
                led0_g <= '0';
                led0_b <= '1';


            ------------------------------------------------------------
            -- REVERB -> MAGENTA
            -- R + B
            ------------------------------------------------------------
            when "010" =>
                led0_r <= '1';
                led0_g <= '0';
                led0_b <= '1';


            ------------------------------------------------------------
            -- CHORUS -> AMARILLO
            -- R + G
            ------------------------------------------------------------
            when "011" =>
                led0_r <= '1';
                led0_g <= '1';
                led0_b <= '0';


            ------------------------------------------------------------
            -- DELAY -> ROJO
            ------------------------------------------------------------
            when "100" =>
                led0_r <= '1';
                led0_g <= '0';
                led0_b <= '0';


            ------------------------------------------------------------
            -- FLANGER -> VERDE
            -- G
            ------------------------------------------------------------
            when "101" =>
                led0_r <= '0';
                led0_g <= '1';
                led0_b <= '0';


            ------------------------------------------------------------
            -- CUALQUIER OTRO VALOR -> LED APAGADO
            ------------------------------------------------------------
            when others =>
                led0_r <= '0';
                led0_g <= '0';
                led0_b <= '0';

        end case;

    end process;


end Structural;
