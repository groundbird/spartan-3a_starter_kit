library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity dac is

  port (
    CLK      : in  std_logic;
    ROT_C    : in  std_logic;
    DAC_CS   : out std_logic;
    DAC_CLR  : out std_logic;
    SPI_MOSI : out std_logic;
    SPI_SCK  : out std_logic;
    D        : in  std_logic_vector(7 downto 0);
    Q        : out std_logic_vector(7 downto 0));

end entity dac;

architecture Behavioral of dac is

  signal rst  : std_logic;
  signal reg  : std_logic_vector(31 downto 0) := (others => '0');

begin

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
                     reg(15 downto 4) <= (D & "0000");
                     reg(19 downto 16) <= "0000";
                     SPI_MOSI <= reg(31);
          when 33 => DAC_CS <= '1';
          when 64 => cnt := 0;
          when others => SPI_MOSI <= reg(31 - ((cnt - 1) mod 32));
        end case;
      end if;
    end if;
  end process;

  rst     <= ROT_C;
  SPI_SCK <= not CLK;
  DAC_CLR <= not rst;
  Q       <= D;
  
end architecture Behavioral;
