----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:36:02 03/31/2014 
-- Design Name: 
-- Module Name:    adc - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity adc is
    Port (
           -- general
           CLK      : in  STD_LOGIC;
           RST      : in  STD_LOGIC;
           SPI_SCK  : out STD_LOGIC;
           -- I/O
           D        : in  STD_LOGIC_VECTOR(8 downto 0);
           Q        : out std_logic_vector(1 downto 0);
           -- AMP
           SPI_MOSI : out STD_LOGIC;
           AMP_CS   : out STD_LOGIC;
           AMP_SHDN : out STD_LOGIC;
           AMP_DOUT : in  STD_LOGIC;
           -- ADC
           AD_CONV  : out STD_LOGIC;
           AD_DOUT  : in  STD_LOGIC;
           -- DEBUG
           LED      : out STD_LOGIC_VECTOR(7 downto 0));
end adc;

architecture Behavioral of adc is

  -- state
  type state_type is (s_reset, s_idle, s_send);
  signal state : state_type;

  -- signal
  signal trigger : std_logic;
  signal state_trigger : std_logic_vector(1 downto 0);
  signal busy : std_logic;
  signal error : std_logic;
  signal spi_sck_state : std_logic_vector(1 downto 0);
  signal char_cnt : std_logic_vector(2 downto 0);
  signal spi_data : std_logic_vector(8 downto 0);
  signal spi_sck_cnt : std_logic_vector(1 downto 0);

  -- assign
  state_trigger <= busy & error;
  AMP_OUT <= AMP_CS & SPI_SCK & SPI_MOSI;
  trigger & data <= INPUT;
  busy <= when state != s_idle;
    
begin
  state_updates: process(CLK, RST)
  begin
    if (CLK'event and CLK = '1') then
      if (RST = '1') then
        state <= s_reset;
      else
        case state is
          when s_reset =>
            state <= s_idel;
          when s_idel => if (trigger = '1') then
            state <= s_send;
          end if;
          when s_send => if (spi_sck_state = '10') then
            if (char_cnt = '111') then
              state <= s_idel;
            end if;
           if (spi_data(8) != AMP_DOUT) then
             state <= s_idel;
           end if;
          end if;
        end case;
      end if;
    end if;

    process(CLK, RST)
    begin
      if (CLK'event and CLK = '1') then
        if (RST = '1') then
          error <= '0';
        else
          case state is
            when s_reset => error <= '0';
            when s_idle =>  error <= '1';
            when s_send =>
              if (spi_sck_state = '01') then
                if (spi_data(8) != AMP_DOUT) then
                  error <= '1';
                end if;
              end if;
          end case;
        end if;
      end if;
    end process;

--    clk_10M: process(CLK, RST)
--    begin
--      if (CLK'event and CLK = '1') then
--        if (RST = '1') then
--          spi_sck_state = '00';
--          spi_sck_cnt = '00';
--        else
--          case state is
--            when s_reset =>
--              spi_sck_state <= '00';
--              spi_sck_cnt <= '00';
--            when s_idle =>
--              spi_sck_state <= '00';
--              spi_sck_cnt <= '00';
--            when s_send =>
--              if (spi_sck_cnt == '10') then
--                spi_sck_cnt <= '00';
--                spi_sck_state <= ((not spi_sck_state(1)) & spi_sck_state(1));
--              else
--                spi_sck_cnt <= spi_sck_cnt + 1;
--                spi_sck_state <= (spi_sck_state(1) & spi_sck_state(1));
--              end if;
--          end case;
--        end if
--      end if
--    end process;

    clk_10M: process(CLK, RST)
    begin
      if (CLK'event and CLK = '1') then
        if (RST = '1') then
          counter <= (others => '0');
        else
          case state is
--            when s_reset => counter <= (others => '0');
--            when s_idle  => counter <= (others => '0');
            when s_send  =>
              if (counter = X"989680") then
                clk_10M <= '1';
                counter <= (others => '0');
              else
                counter <= counter + 1;
              end if;
            when others => counter <= (others => '0');
          end case;
    end process;

    process(CLK, RST)
    begin
      if (CLK'event and CLK = '1') then
        if (RST = '1') then
          spi_data <= (others => '0');
        else
          case state is
            when s_reset => spi_data <= (others => '0');
            when s_idle => spi_data <= ('0' & spi_data(7 downto 0));
            when s_send => spi_data <= (spi_data(7 downto 0), '0');
          end case;
        end if;
      end if;
    end process;

    process(CLK, RST)
    begin
      if (CLK'event and CLK = '1') then
        if (RST = '1') then
          char_cnt = (others => '0');
        else
          case state is
            when s_reset => char_cnt <= (others => '0');
            when s_idle => char_cnt <= (others => '0');
            when s_send =>
              if (spi_sck_state = '01') then
                char_cnt <= char_cnt + 1;
              end if;
          end case;

end Behavioral;

