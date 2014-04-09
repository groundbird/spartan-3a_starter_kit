library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dac is

  port (
    CLK      : in  std_logic;
    PUSH_SW  : in  std_logic;
    ROT_A    : in  std_logic;
    ROT_B    : in  std_logic;
    DAC_CS   : out std_logic;
    DAC_CLR  : out std_logic;
    SPI_MOSI : out std_logic;
    SPI_SCK  : out std_logic;
    LED      : out std_logic_vector(7 downto 0));

end entity dac;

architecture Behavioral of dac is

  component rotary_switch is
    generic (N : integer);
    port (
      CLK     : in  std_logic;
      PUSH_SW : in  std_logic;
      ROT_A   : in  std_logic;
      ROT_B   : in  std_logic;
      Q       : out std_logic_vector(N-1 downto 0));
  end component rotary_switch;

  signal rst  : std_logic;
  signal data : std_logic_vector(7 downto 0);
  signal reg  : std_logic_vector(31 downto 0) := (others => '0');

begin

  C1 : rotary_switch
    generic map (N => 8)
    port map (CLK, PUSH_SW, ROT_A, ROT_B, data);

  process(CLK)
  variable cnt : integer range 0 to 64 := 0;
  begin
    if (CLK'event and CLK = '1') then
      if (rst = '1') then
        reg(23 downto 20) <= "0011";    -- COMMAND[3:0]
        reg(19 downto 16) <= "0000";    -- ADDRESS (DAC_A)
        cnt := 0;
        DAC_CS <= '1';
      else
        cnt := cnt + 1;
        case cnt is
          when 1  => DAC_CS <= '0';
                     reg(15 downto 4) <= (data & "0000");
                     reg(19 downto 16) <= "0000";
                     SPI_MOSI <= reg(31);
          when 33 => DAC_CS <= '1';
          when 64 => cnt := 0;
          when others => SPI_MOSI <= reg(31 - ((cnt - 1) mod 32));
        end case;
      end if;
    end if;
  end process;

  rst     <= PUSH_SW;
  SPI_SCK <= not CLK;
  DAC_CLR <= not rst;
  LED     <= data;
  
end architecture Behavioral;
