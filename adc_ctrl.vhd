library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity adc_ctrl is

  port (
    CLK : in  std_logic;
    RST : in  std_logic;
    D   : in  std_logic_vector(1  downto 0);  -- trg, ADC_OUT
    Q   : out std_logic_vector(36 downto 0)); -- busy, adc_data[33:0],
                                              -- AD_CONV, SPI_SCK
end entity adc_ctrl;

architecture Behavioral of adc_ctrl is

  component oneshot_plus is
    port (
      CLK : in  std_logic;
      D   : in  std_logic;
      Q   : out std_logic);
  end component oneshot_plus;

  type state_type is (S_reset, S_idle, S_receive);
  signal state        : state_type;
  signal char_cnt     : std_logic_vector(5  downto 0);
  signal adc_data     : std_logic_vector(33 downto 0);
  signal adc_data_reg : std_logic_vector(33 downto 0);
  signal busy         : std_logic;
  signal trg          : std_logic;
  signal SPI_SCK      : std_logic;
  signal AD_CONV      : std_logic;
  signal ADC_OUT      : std_logic;
  
begin  -- architecture Behavioral

  trg     <= D(1);
  ADC_OUT <= D(0);
  Q       <= busy & adc_data_reg & AD_CONV & SPI_SCK;
  SPI_SCK <= not CLK when state = S_receive else '0';
  busy    <= '1' when state /= S_idle else '0';

  C0 : oneshot_plus port map (CLK, trg, AD_CONV);

  process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if RST = '1' then
        adc_data <= (others => '0');
      else
        case state is
          when S_reset   => adc_data <= (others => '0');
          when S_idle    => adc_data <= (others => '0');
          when S_receive => adc_data <= adc_data(32 downto 0) & ADC_OUT;
            if char_cnt = "100010" then
              adc_data_reg <= adc_data;
            end if;
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
          when S_reset   => char_cnt <= (others => '0');
          when S_idle    => char_cnt <= (others => '0');
          when S_receive => char_cnt <= char_cnt + 1;
        end case;
      end if;
    end if;
  end process;

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
              state <= S_receive;
            end if;
          when S_receive =>
            if char_cnt = "100010" then
              state <= S_idle;
            end if;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
