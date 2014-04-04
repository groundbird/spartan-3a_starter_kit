library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity chattering is
  
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    INPUT  : in  std_logic;
    OUTPUT : out std_logic);

end entity chattering;

architecture behaivioral of chattering is

  signal counter : std_logic_vector(15 downto 0);
  
begin  -- architecture RTL

  process(CLK, RST)
  begin
    if (CLK'event and CLK = '1') then
      if (RST = '1') then
        counter <= (others => '0');
      else
        counter <= counter + 1;
        if (counter = X"1111") then
          OUTPUT <= INPUT;
        end if;
      end if;
    end if;
  end process;

end architecture behaivioral;
