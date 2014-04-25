library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity oneshot_plus is
  
  port (
    CLK : in  std_logic;
    D   : in  std_logic;
    Q   : out std_logic);

end entity oneshot_plus;

architecture Behavioral of oneshot_plus is

  signal reg : std_logic;
  
begin  -- architecture Behavioral

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      reg <= D;
    end if;
  end process;
  Q <= D and (not reg);
end architecture Behavioral;
