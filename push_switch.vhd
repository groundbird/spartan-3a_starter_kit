library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity push_switch is
  
  port (
    CLK    : in  std_logic;
    INPUT  : in  std_logic;
    OUTPUT : out std_logic);

end entity push_switch;

architecture behaivioral of push_switch is

  signal edge : std_logic;
  
begin  -- architecture behaivioral

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      edge <= INPUT;
    end if;
  end process;
  OUTPUT <= (not edge) and INPUT;
end architecture behaivioral;
