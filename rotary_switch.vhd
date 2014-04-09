library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rotary_switch is

  generic (N : integer);
  port (
    CLK     : in  std_logic;
    PUSH_SW : in  std_logic;
    ROT_A   : in  std_logic;
    ROT_B   : in  std_logic;
    Q       : out std_logic_vector(N-1 downto 0));

end entity rotary_switch;

architecture Behavioral of rotary_switch is

  signal rst        : std_logic;
  signal rot_a_sync : std_logic;
  signal rot_b_sync : std_logic;
  signal cnt        : std_logic_vector(N-1 downto 0);
  signal rot_a_reg  : std_logic;
  signal rot_b_reg  : std_logic;

begin  -- architecture Behavioral

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      rot_a_sync <= ROT_A;
      rot_b_sync <= ROT_B;
    end if;
  end process;
  
  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if (rst = '1') then
        cnt <= (others => '0');
      else
        rot_a_reg <= rot_a_sync;
        rot_b_reg <= rot_b_sync;
        if (rot_b_sync = '0') then
          if (rot_a_sync = '1' and rot_a_reg = '0') then
            cnt <= cnt - 1;
          elsif (rot_a_sync = '0' and rot_a_reg = '1') then
            cnt <= cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  rst <= PUSH_SW;
  Q   <= cnt;
  
end architecture Behavioral;
