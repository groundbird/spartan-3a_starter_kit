--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:42:28 04/25/2014
-- Design Name:   
-- Module Name:   C:/Users/gb/Dropbox/hikaru/spartan-3a_starter_kit/dac2adc/top_dac2adc_tb.vhd
-- Project Name:  dac2adc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_dac2adc
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_dac2adc_tb IS
END top_dac2adc_tb;
 
ARCHITECTURE behavior OF top_dac2adc_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_dac2adc
    PORT(
         CLK : IN  std_logic;
         ROT_A : IN  std_logic;
         ROT_B : IN  std_logic;
         ROT_C : IN  std_logic;
         SLIDE_SW : IN  std_logic;
         DAC_CS : OUT  std_logic;
         DAC_CLR : OUT  std_logic;
         ADC_OUT : IN  std_logic;
         AMP_CS : OUT  std_logic;
         AMP_SHDN : OUT  std_logic;
         SPI_SCK : OUT  std_logic;
         SPI_MOSI : OUT  std_logic;
         AD_CONV : OUT  std_logic;
         LED : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal ROT_A : std_logic := '0';
   signal ROT_B : std_logic := '0';
   signal ROT_C : std_logic := '0';
   signal SLIDE_SW : std_logic := '0';
   signal ADC_OUT : std_logic := '0';

 	--Outputs
   signal DAC_CS : std_logic;
   signal DAC_CLR : std_logic;
   signal AMP_CS : std_logic;
   signal AMP_SHDN : std_logic;
   signal SPI_SCK : std_logic;
   signal SPI_MOSI : std_logic;
   signal AD_CONV : std_logic;
   signal LED : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_dac2adc PORT MAP (
          CLK => CLK,
          ROT_A => ROT_A,
          ROT_B => ROT_B,
          ROT_C => ROT_C,
          SLIDE_SW => SLIDE_SW,
          DAC_CS => DAC_CS,
          DAC_CLR => DAC_CLR,
          ADC_OUT => ADC_OUT,
          AMP_CS => AMP_CS,
          AMP_SHDN => AMP_SHDN,
          SPI_SCK => SPI_SCK,
          SPI_MOSI => SPI_MOSI,
          AD_CONV => AD_CONV,
          LED => LED
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
