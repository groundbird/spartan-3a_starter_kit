library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity amp_ctrl is

  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    D   : in  std_logic_vector(8 downto 0);  -- trg, gain[7:0]
    Q   : out std_logic_vector(4 downto 0)); -- busy, AMP_CS, AMP_SHDN
                                             -- SPI_SCK, SPI_MOSI
end entity amp_ctrl;

architecture Behavioral of amp_ctrl is

  type state_type is (S_reset, S_idle, S_send);
  signal state        : state_type;
  signal trg          : std_logic;
  signal gain         : std_logic_vector(7 downto 0);
  signal busy         : std_logic;
  signal AMP_CS       : std_logic;
  signal AMP_SHDN     : std_logic;
  signal SPI_SCK      : std_logic;
  signal spi_sck_up   : std_logic;
  signal spi_sck_down : std_logic;
  signal SPI_MOSI     : std_logic;
  signal spi_sck_reg  : std_logic_vector(1 downto 0);
  signal spi_sck_cnt  : std_logic_vector(1 downto 0);
  signal spi_data     : std_logic_vector(8 downto 0);
  signal char_cnt     : std_logic_vector(2 downto 0);
  
begin  -- architecture Behavioral
  
  trg          <= D(8);
  gain         <= D(7 downto 0);
  Q            <= busy & AMP_CS & AMP_SHDN & SPI_SCK & SPI_MOSI;
  busy         <= '1' when state /= S_idle  else '0';
  AMP_CS       <= '0' when state  = S_send  else '1';
  AMP_SHDN     <= '1' when state  = S_reset else '0';
  SPI_SCK      <= spi_sck_reg(1) when state = S_send else '0';
  spi_sck_up   <= '1' when spi_sck_reg = "10" else '0';
  spi_sck_down <= '1' when spi_sck_reg = "01" else '0';
--  SPI_MOSI     <= spi_data(7) when state = S_send else '0';
  SPI_MOSI     <= spi_data(7);
  
  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        state <= S_reset;
      else
        case state is
          when S_reset => state <= S_idle;
          when S_idle  =>
            if trg = '1' then
              state <= S_send;
            end if;
          when S_send  =>
            if (spi_sck_down = '1' and char_cnt = "111") then
              state <= S_idle;
            end if;
        end case;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        spi_sck_reg <= "00";
        spi_sck_cnt <= "00";
      else
        case state is
          when S_reset => spi_sck_reg <= "00";
                          spi_sck_cnt <= "00";
          when S_idle  => spi_sck_reg <= "00";
                          spi_sck_cnt <= "00";
          when S_send  =>
            if spi_sck_cnt = "10" then
              spi_sck_cnt <= "00";
              spi_sck_reg <= not spi_sck_reg(1) & spi_sck_reg(1);
            else
              spi_sck_cnt <= spi_sck_cnt + 1;
              spi_sck_reg <= spi_sck_reg(1) & spi_sck_reg(1);
            end if;
        end case;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        spi_data <= (others => '0');
      else
        case state is
          when S_reset => spi_data <= (others => '0');
          when S_idle  => spi_data <= '0' & gain;
          when S_send  =>
            if spi_sck_up = '1' then
              spi_data <= spi_data(7 downto 0) & '0';
            end if;
        end case;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        char_cnt <= "000";
      else
        case state is
          when S_reset => char_cnt <= "000";
          when S_idle  => char_cnt <= "000";
          when S_send  =>
            if spi_sck_down = '1' then
              char_cnt <= char_cnt + 1;
            end if;
        end case;
      end if;
    end if;
  end process;
  
end architecture Behavioral;
