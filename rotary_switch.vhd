library ieee;
use ieee.std_logic_1164.all;

entity rotary_switch is
  generic (N : integer);
  port (
    CLK   : in  std_logic;
    RST   : in  std_logic;
    ROT_A : in  std_logic;
    ROT_B : in  std_logic;
    Q     : out std_logic_vector(N-1 downto 0));
end entity rotary_switch;

architecture Behavioral of rotary_switch is
  signal encoder : std_logic_vector(1 downto 0);
  encoder <= ROT_A & ROT_B;
  process(CLK, RST)
    variable cnt : integer range 0 to N-1 := 0;
  begin
    if (CLK'event and CLK = '1') then
      if (RST = '1') then
        
      else
        case encoder is
          when "00" => cnt +;
          when others => null;
        end case;
      end if;
    end if;
  end process;
begin  -- architecture Behavioral

  

end architecture Behavioral;
