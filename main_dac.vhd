library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity main_dac is

  port (
    CLK      : in  std_logic;
    ROT_A    : in  std_logic;
    ROT_B    : in  std_logic;
    ROT_C    : in  std_logic;
    DAC_CS   : out std_logic;
    DAC_CLR  : out std_logic;
    SPI_MOSI : out std_logic;
    SPI_SCK  : out std_logic;
    LED      : out std_logic_vector(7 downto 0));

end entity main_dac;

architecture Behavioral of main_dac is

  component rotary_switch
    generic (N : integer);
    port (
      CLK : in  std_logic;
		RST : in  std_logic;
		D   : in  std_logic_vector(1 downto 0);
      Q   : out std_logic_vector(N-1 downto 0));
  end component rotary_switch;

  component dac
    port (
      CLK      : in  std_logic;
--      ROT_A    : in  std_logic;
--      ROT_B    : in  std_logic;
      ROT_C    : in  std_logic;
      DAC_CS   : out std_logic;
      DAC_CLR  : out std_logic;
      SPI_MOSI : out std_logic;
      SPI_SCK  : out std_logic;
      D        : in  std_logic_vector(7 downto 0);
      Q        : out std_logic_vector(7 downto 0));
  end component dac;

  signal data  : std_logic_vector(7 downto 0);
  signal dac_q : std_logic_vector(7 downto 0);
  
begin  -- architecture Behavioral

  C1 : rotary_switch
    generic map (N => 8)
    port map (CLK, ROT_A, ROT_B, ROT_C, data);
  C2 : dac port map (CLK, ROT_C, DAC_CS, DAC_CLR, SPI_MOSI, SPI_SCK, data, dac_q);

  LED <= dac_q;

end architecture Behavioral;
