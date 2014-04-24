library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity dac2adc is

  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    D   : in  std_logic_vector(2  downto 0);  -- ADC_OUT, ROT_A, ROT_B
    Q   : out std_logic_vector(40 downto 0)); -- AMP_CS, AMP_SHDN, AD_CONV
                                              -- DAC_CS, DAC_CLR
                                              -- SPI_SCK, SPI_MOSI
                                              -- adc_data[33:0]
end entity dac2adc;

architecture Behavioral of dac2adc is

  component rotary_switch is
    generic (N : integer);
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      D   : in  std_logic_vector(1   downto 0);
      Q   : out std_logic_vector(N-1 downto 0));
  end component rotary_switch;

  component dac_ctrl is
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      D   : in  std_logic_vector(32 downto 0);
      Q   : out std_logic_vector(4  downto 0));
  end component dac_ctrl;
  
  component amp_ctrl is
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      D   : in  std_logic_vector(8 downto 0);
      Q   : out std_logic_vector(4 downto 0));
  end component amp_ctrl;

  component adc_ctrl is
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      D   : in  std_logic_vector(1  downto 0);
      Q   : out std_logic_vector(36 downto 0));
  end component adc_ctrl;

  component oneshot_plus is
    port (
      CLK : in  std_logic;
      D   : in  std_logic;
      Q   : out std_logic);
  end component oneshot_plus;

  -- state
  type state_type is (S_idle, S_dac, S_amp, S_adc);
  signal state : state_type;
  -- rotary_switch
  signal ROT_A        : std_logic;
  signal ROT_B        : std_logic;
  signal d_rot        : std_logic_vector(1 downto 0);
  signal q_rot        : std_logic_vector(7 downto 0);
  -- dac_ctrl
  signal mode_dac     : std_logic;
  signal trg_dac      : std_logic;
  signal busy_dac     : std_logic;  
  signal dac_data     : std_logic_vector(31 downto 0);
  signal DAC_CS       : std_logic;
  signal DAC_CLR      : std_logic;
  signal spi_sck_dac  : std_logic;
  signal spi_mosi_dac : std_logic;
  signal d_dac        : std_logic_vector(32 downto 0);
  signal q_dac        : std_logic_vector(4 downto 0);
  -- amp_ctrl
  signal mode_amp     : std_logic;
  signal trg_amp      : std_logic;
  signal busy_amp     : std_logic;  
  signal gain         : std_logic_vector(7 downto 0) := "00010001";
  signal AMP_CS       : std_logic;
  signal spi_sck_amp  : std_logic;
  signal spi_mosi_amp : std_logic;
  signal d_amp        : std_logic_vector(8 downto 0);
  signal q_amp        : std_logic_vector(4 downto 0);
  -- adc_ctrl
  signal mode_adc     : std_logic;
  signal trg_adc      : std_logic;
  signal busy_adc     : std_logic;
  signal AD_CONV      : std_logic;
  signal AMP_SHDN     : std_logic;
  signal ADC_OUT      : std_logic;
  signal adc_data     : std_logic_vector(33 downto 0);
  signal spi_sck_adc  : std_logic;
  signal d_adc        : std_logic_vector(1 downto 0);
  signal q_adc        : std_logic_vector(36 downto 0);
  -- common
  signal SPI_SCK      : std_logic;
  signal SPI_MOSI     : std_logic;
  signal cnt          : std_logic_vector(7 downto 0) := (others => '0');
  
begin  -- architecture Behavioral

  -- common
  Q        <= AMP_CS & AMP_SHDN & AD_CONV &
              DAC_CS & DAC_CLR &
              SPI_SCK & SPI_MOSI & adc_data;
  SPI_SCK  <= spi_sck_dac  when state = S_dac else
              spi_sck_amp  when state = S_amp else
              spi_sck_adc  when state = S_adc else '0';
  SPI_MOSI <= spi_mosi_dac when state = S_dac else
              spi_mosi_amp when state = S_amp else '0';
  -- rotary_switch
  ROT_A <= D(1);
  ROT_B <= D(0);
  d_rot <= ROT_A & ROT_B;
  dac_data(23 downto 20) <= "0011"; -- command[3:0]
  dac_data(19 downto 16) <= "0000"; -- address (use DAC_A)
  dac_data(15 downto  4) <= q_rot & "0000";
  -- dac_ctrl
  d_dac        <= trg_dac & dac_data;
  mode_dac     <= '1' when state = S_dac else '0';
  busy_dac     <= q_dac(4);
  DAC_CS       <= q_dac(3) when state = S_dac else '1';
  DAC_CLR      <= q_dac(2);
  spi_sck_dac  <= q_dac(1) when state = S_dac else '0';
  spi_mosi_dac <= q_dac(0);
  -- amp_ctrl
  d_amp        <= trg_amp & gain;
  mode_amp     <= '1' when state = S_amp else '0';
  busy_amp     <= q_amp(4);
  AMP_CS       <= q_amp(3) when state = S_amp else '1';
  AMP_SHDN     <= q_amp(2);
  spi_sck_amp  <= q_amp(1) when state = S_amp else '0';
  spi_mosi_amp <= q_amp(0);
  -- adc_ctrl
  ADC_OUT     <= D(2);
  d_adc       <= trg_adc & ADC_OUT;
  mode_adc    <= '1' when state = S_adc else '0';
  busy_adc    <= q_adc(36);
  adc_data    <= q_adc(35 downto 2);
  AD_CONV     <= q_adc(1) when state = S_adc else '0';
  spi_sck_adc <= q_adc(0) when state = S_adc else '0';

  U0 : rotary_switch generic map (N => 8) 
	                  port map (CLK, RST, d_rot, q_rot);
  U1 : dac_ctrl      port map (CLK, RST, d_dac, q_dac);
  U2 : amp_ctrl      port map (CLK, RST, d_amp, q_amp);
  U3 : adc_ctrl      port map (CLK, RST, d_adc, q_adc);
  U4 : oneshot_plus  port map (CLK, mode_dac, trg_dac);
  U5 : oneshot_plus  port map (CLK, mode_amp, trg_amp);
  U6 : oneshot_plus  port map (CLK, mode_adc, trg_adc);
    
  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        cnt <= (others => '0');
        state <= S_idle;
      else
        cnt <= cnt + 1;
        case state is
          when S_idle => state <= S_dac;
          when S_dac  =>
            if cnt(5) = '1' then
              state <= S_amp;
              cnt <= (others => '0');
            end if;
          when S_amp  =>
            if cnt(6) = '1' then
              state <= S_adc;
				  cnt   <= (others => '0');
            end if;
          when S_adc  =>
            --if cnt(6) = '1' then
				if cnt(5) = '1' then
              state <= S_idle;
              cnt   <= (others => '0');
            end if;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
