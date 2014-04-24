library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity dac_ctrl is
  
  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    D   : in  std_logic_vector(32 downto 0);  -- trg, dac_data[31:0]
    Q   : out std_logic_vector(4  downto 0)); -- busy, DAC_CS, DAC_CLR
                                              -- SPI_SCK, SPI_MOSI
end entity dac_ctrl;

architecture Behavioral of dac_ctrl is

  type state_type is (S_reset, S_idle, S_send);
  signal state    : state_type;
  signal trg      : std_logic;
  signal dac_data : std_logic_vector(31 downto 0);
  signal spi_data : std_logic_vector(32 downto 0);
  signal busy     : std_logic;
  signal char_cnt : std_logic_vector(5 downto 0);
  signal DAC_CS   : std_logic;
  signal DAC_CLR  : std_logic;
  signal SPI_SCK  : std_logic;
  signal SPI_MOSI : std_logic;
  
begin  -- architecture Behavioral

  trg      <= D(32);
  dac_data <= D(31 downto 0);
  Q        <= busy & DAC_CS & DAC_CLR & SPI_SCK & SPI_MOSI;
  busy     <= '1' when state /= S_idle  else '0';
  DAC_CS   <= '0' when state  = S_send  else '1';
  DAC_CLR  <= '0' when state  = S_reset else '1';
  SPI_SCK  <= not CLK when state = S_send  else '0';
  SPI_MOSI <= spi_data(31);

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
            if char_cnt(5) = '1' then
				--if char_cnt = "11111" then
              state <= S_idle;
            end if;
        end case;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if (CLK'event and CLK = '0') then
      if RST = '1' then
        spi_data <= (others => '0');
      else
        case state is
          when S_reset => spi_data <= (others => '0');
          when S_idle  => spi_data <= '0' & dac_data;
          when S_send  => spi_data <= spi_data(31 downto 0) & '0';
        end case;
      end if;
    end if;
  end process;

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        char_cnt <= (others => '0');
      else
        case state is
          when S_reset => char_cnt <= (others => '0');
          when S_idle  => char_cnt <= (others => '0');
          when S_send  => char_cnt <= char_cnt + 1;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
