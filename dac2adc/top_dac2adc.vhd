library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity top_dac2adc is
  port (
    CLK      : in  std_logic;
    ROT_A    : in  std_logic;
    ROT_B    : in  std_logic;
    ROT_C    : in  std_logic;
    SLIDE_SW : in  std_logic;
    DAC_CS   : out std_logic;
    DAC_CLR  : out std_logic;
    ADC_OUT  : in  std_logic;
    AMP_CS   : out std_logic;
    AMP_SHDN : out std_logic;
    SPI_SCK  : out std_logic;
    SPI_MOSI : out std_logic;
    AD_CONV  : out std_logic;
    LED      : out std_logic_vector(7 downto 0));
end entity top_dac2adc;

architecture Behavioral of top_dac2adc is

  component dac2adc is
    port (
      CLK : in  std_logic;
      RST : in  std_logic;
      D   : in  std_logic_vector(2  downto 0);
      Q   : out std_logic_vector(40 downto 0));
  end component dac2adc;

  signal d_rot    : std_logic_vector(1  downto 0);
  signal q_rot    : std_logic_vector(7  downto 0);
  signal d_main   : std_logic_vector(2  downto 0);
  signal q_main   : std_logic_vector(40 downto 0);
  signal adc_data : std_logic_vector(33 downto 0);
  signal ch0, ch1 : std_logic_vector(13 downto 0) := (others => '0');
  
begin  -- architecture Behavioral

  -- input
  d_main(2) <= ADC_OUT;
  d_main(1) <= ROT_A;
  d_main(0) <= ROT_B;
  -- output
  AMP_CS   <= q_main(40);
  AMP_SHDN <= q_main(39);
  AD_CONV  <= q_main(38);
  DAC_CS   <= q_main(37);
  DAC_CLR  <= q_main(36);
  SPI_SCK  <= q_main(35);
  SPI_MOSI <= q_main(34);
  adc_data <= q_main(33 downto 0);
  ch0      <= adc_data(31 downto 18);
  ch1      <= adc_data(15 downto  2);
--  LED      <= ch0(13 downto 6) when SLIDE_SW = '0' else -- ch. 0
--              ch1(13 downto 6);                         -- ch. 1
  LED      <= ch0(13) & (not ch0(12 downto 6)) when SLIDE_SW = '0' else
              ch1(13) & (not ch1(12 downto 6));
  test_dac_adc : dac2adc port map (CLK, ROT_C, d_main, q_main);

end architecture Behavioral;
