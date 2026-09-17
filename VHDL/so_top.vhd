library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity so_top is
    port (
        ----------------------------------------------------------------
        -- RELOJ PRINCIPAL DE LA CORA Z7
        ----------------------------------------------------------------
        clk : in std_logic;

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
        led0_b : out std_logic;

        ----------------------------------------------------------------
        -- DDR DEL ZYNQ
        ----------------------------------------------------------------
        DDR_addr    : inout std_logic_vector(14 downto 0);
        DDR_ba      : inout std_logic_vector(2 downto 0);
        DDR_cas_n   : inout std_logic;
        DDR_ck_n    : inout std_logic;
        DDR_ck_p    : inout std_logic;
        DDR_cke     : inout std_logic;
        DDR_cs_n    : inout std_logic;
        DDR_dm      : inout std_logic_vector(3 downto 0);
        DDR_dq      : inout std_logic_vector(31 downto 0);
        DDR_dqs_n   : inout std_logic_vector(3 downto 0);
        DDR_dqs_p   : inout std_logic_vector(3 downto 0);
        DDR_odt     : inout std_logic;
        DDR_ras_n   : inout std_logic;
        DDR_reset_n : inout std_logic;
        DDR_we_n    : inout std_logic;

        ----------------------------------------------------------------
        -- FIXED IO DEL ZYNQ
        ----------------------------------------------------------------
        FIXED_IO_ddr_vrn  : inout std_logic;
        FIXED_IO_ddr_vrp  : inout std_logic;
        FIXED_IO_mio      : inout std_logic_vector(53 downto 0);
        FIXED_IO_ps_clk   : inout std_logic;
        FIXED_IO_ps_porb  : inout std_logic;
        FIXED_IO_ps_srstb : inout std_logic
    );
end so_top;


architecture Structural of so_top is

    --------------------------------------------------------------------
    -- SEÑAL DE CONTROL PROCEDENTE DEL AXI GPIO
    --------------------------------------------------------------------

    signal effect_control : std_logic_vector(2 downto 0);


    --------------------------------------------------------------------
    -- COMPONENTE SYSTEM_WRAPPER
    --------------------------------------------------------------------

    component system_wrapper
        port (
            DDR_addr             : inout std_logic_vector(14 downto 0);
            DDR_ba               : inout std_logic_vector(2 downto 0);
            DDR_cas_n            : inout std_logic;
            DDR_ck_n             : inout std_logic;
            DDR_ck_p             : inout std_logic;
            DDR_cke              : inout std_logic;
            DDR_cs_n             : inout std_logic;
            DDR_dm               : inout std_logic_vector(3 downto 0);
            DDR_dq               : inout std_logic_vector(31 downto 0);
            DDR_dqs_n            : inout std_logic_vector(3 downto 0);
            DDR_dqs_p            : inout std_logic_vector(3 downto 0);
            DDR_odt              : inout std_logic;
            DDR_ras_n            : inout std_logic;
            DDR_reset_n          : inout std_logic;
            DDR_we_n             : inout std_logic;
            FIXED_IO_ddr_vrn     : inout std_logic;
            FIXED_IO_ddr_vrp     : inout std_logic;
            FIXED_IO_mio         : inout std_logic_vector(53 downto 0);
            FIXED_IO_ps_clk      : inout std_logic;
            FIXED_IO_ps_porb     : inout std_logic;
            FIXED_IO_ps_srstb    : inout std_logic;
            effect_control_tri_o : out std_logic_vector(2 downto 0)
        );
    end component;

begin

    --------------------------------------------------------------------
    -- 1. PROCESSING SYSTEM + AXI GPIO
    --------------------------------------------------------------------

    system_inst : system_wrapper
        port map (
            DDR_addr             => DDR_addr,
            DDR_ba               => DDR_ba,
            DDR_cas_n            => DDR_cas_n,
            DDR_ck_n             => DDR_ck_n,
            DDR_ck_p             => DDR_ck_p,
            DDR_cke              => DDR_cke,
            DDR_cs_n             => DDR_cs_n,
            DDR_dm               => DDR_dm,
            DDR_dq               => DDR_dq,
            DDR_dqs_n            => DDR_dqs_n,
            DDR_dqs_p            => DDR_dqs_p,
            DDR_odt              => DDR_odt,
            DDR_ras_n            => DDR_ras_n,
            DDR_reset_n          => DDR_reset_n,
            DDR_we_n             => DDR_we_n,
            FIXED_IO_ddr_vrn     => FIXED_IO_ddr_vrn,
            FIXED_IO_ddr_vrp     => FIXED_IO_ddr_vrp,
            FIXED_IO_mio         => FIXED_IO_mio,
            FIXED_IO_ps_clk      => FIXED_IO_ps_clk,
            FIXED_IO_ps_porb     => FIXED_IO_ps_porb,
            FIXED_IO_ps_srstb    => FIXED_IO_ps_srstb,
            effect_control_tri_o => effect_control
        );


    --------------------------------------------------------------------
    -- 2. PROCESAMIENTO DE AUDIO
    --------------------------------------------------------------------

    audio_inst : entity work.audio_efectos_final
        port map (
            clk            => clk,
            effect_command => unsigned(effect_control),

            adc_sck        => adc_sck,
            adc_bck        => adc_bck,
            adc_lrck       => adc_lrck,
            adc_dout       => adc_dout,

            dac_bck        => dac_bck,
            dac_lrck       => dac_lrck,
            dac_din        => dac_din,

            led0_r         => led0_r,
            led0_g         => led0_g,
            led0_b         => led0_b
        );

end Structural;
