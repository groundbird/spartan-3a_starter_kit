library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity binary_counter is
  generic (N : integer);
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    INPUT  : in  std_logic;
    OUTPUT : out std_logic_vector(N-1 downto 0));

end entity binary_counter;

architecture behaivioral of binary_counter is

  signal counter : std_logic_vector(N-1 downto 0);
  
begin  -- architecture behaivioral

  process(CLK, RST)
  begin
    if (CLK'event and CLK = '1') then
      if (RST = '1') then
        counter <= (others => '0');
      else
        if (INPUT = '1') then
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;
  OUTPUT <= counter;
end architecture behaivioral;
