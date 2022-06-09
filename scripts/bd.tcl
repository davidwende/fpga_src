
################################################################
# This is a generated script based on design: multiphase
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source multiphase_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# all_rstn_sync, fft_top_2, galvo_top, input_top_2, mc_top, mult_add_top_2, peak_top_2, pm_resets, pm_resets, pm_resets, pm_top, pm_top, pm_top, regs, spi_adc_pm, vga, window_top_2

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z015clg485-2
   set_property BOARD_PART trenz.biz:te0715_15_2i:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name multiphase

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:selectio_wiz:*\
xilinx.com:ip:axi_mm2s_mapper:*\
xilinx.com:ip:clk_wiz:*\
xilinx.com:ip:proc_sys_reset:*\
xilinx.com:ip:processing_system7:*\
xilinx.com:ip:xlconcat:*\
xilinx.com:ip:xlconstant:*\
xilinx.com:ip:xlslice:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
all_rstn_sync\
fft_top_2\
galvo_top\
input_top_2\
mc_top\
mult_add_top_2\
peak_top_2\
pm_resets\
pm_resets\
pm_resets\
pm_top\
pm_top\
pm_top\
regs\
spi_adc_pm\
vga\
window_top_2\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 -portmaps { \
   ADDR { physical_name DDR_addr direction IO left 14 right 0 } \
   BA { physical_name DDR_ba direction IO left 2 right 0 } \
   CAS_N { physical_name DDR_cas_n direction IO } \
   CK_N { physical_name DDR_ck_n direction IO } \
   CK_P { physical_name DDR_ck_p direction IO } \
   CKE { physical_name DDR_cke direction IO } \
   CS_N { physical_name DDR_cs_n direction IO } \
   DM { physical_name DDR_dm direction IO left 3 right 0 } \
   DQ { physical_name DDR_dq direction IO left 31 right 0 } \
   DQS_N { physical_name DDR_dqs_n direction IO left 3 right 0 } \
   DQS_P { physical_name DDR_dqs_p direction IO left 3 right 0 } \
   ODT { physical_name DDR_odt direction IO } \
   RAS_N { physical_name DDR_ras_n direction IO } \
   RESET_N { physical_name DDR_reset_n direction IO } \
   WE_N { physical_name DDR_we_n direction IO } \
   } \
  DDR ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $DDR
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports DDR]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 -portmaps { \
   DDR_VRN { physical_name FIXED_IO_ddr_vrn direction IO } \
   DDR_VRP { physical_name FIXED_IO_ddr_vrp direction IO } \
   MIO { physical_name FIXED_IO_mio direction IO left 53 right 0 } \
   PS_CLK { physical_name FIXED_IO_ps_clk direction IO } \
   PS_PORB { physical_name FIXED_IO_ps_porb direction IO } \
   PS_SRSTB { physical_name FIXED_IO_ps_srstb direction IO } \
   } \
  FIXED_IO ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $FIXED_IO
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports FIXED_IO]

  set adc_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name adc_clk_clk_n direction I } \
   CLK_P { physical_name adc_clk_clk_p direction I } \
   } \
  adc_clk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   CONFIG.FREQ_HZ {100000000} \
   ] $adc_clk
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports adc_clk]

  set diff_clk_in_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   } \
  diff_clk_in_0 ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   CONFIG.FREQ_HZ {100000000} \
   ] $diff_clk_in_0
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports diff_clk_in_0]

  set pm0_clk [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name pm0_clk_clk_n direction O } \
   CLK_P { physical_name pm0_clk_clk_p direction O } \
   } \
  pm0_clk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $pm0_clk
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports pm0_clk]

  set pm1_clk [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name pm1_clk_clk_n direction O } \
   CLK_P { physical_name pm1_clk_clk_p direction O } \
   } \
  pm1_clk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $pm1_clk
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports pm1_clk]

  set pm2_clk [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:diff_clock_rtl:1.0 -portmaps { \
   CLK_N { physical_name pm2_clk_clk_n direction O } \
   CLK_P { physical_name pm2_clk_clk_p direction O } \
   } \
  pm2_clk ]
  set_property -dict [ list \
   CONFIG.CAN_DEBUG {false} \
   ] $pm2_clk
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports pm2_clk]


  # Create ports
  set adc_miso [ create_bd_port -dir I adc_miso ]
  set adc_n [ create_bd_port -dir I -from 8 -to 0 adc_n ]
  set adc_p [ create_bd_port -dir I -from 8 -to 0 adc_p ]
  set csn_adc [ create_bd_port -dir O csn_adc ]
  set csn_pm0 [ create_bd_port -dir O csn_pm0 ]
  set csn_pm1 [ create_bd_port -dir O csn_pm1 ]
  set csn_pm2 [ create_bd_port -dir O csn_pm2 ]
  set debug [ create_bd_port -dir O -from 1 -to 0 debug ]
  set down [ create_bd_port -dir O -from 7 -to 0 down ]
  set galvo_csn [ create_bd_port -dir O galvo_csn ]
  set galvo_mosi [ create_bd_port -dir O galvo_mosi ]
  set galvo_sclk [ create_bd_port -dir O galvo_sclk ]
  set mosi_adc [ create_bd_port -dir O mosi_adc ]
  set mosi_pm0 [ create_bd_port -dir O mosi_pm0 ]
  set mosi_pm1 [ create_bd_port -dir O mosi_pm1 ]
  set mosi_pm2 [ create_bd_port -dir O mosi_pm2 ]
  set pm0_miso [ create_bd_port -dir I pm0_miso ]
  set pm0_out_n [ create_bd_port -dir O -from 9 -to 0 pm0_out_n ]
  set pm0_out_p [ create_bd_port -dir O -from 9 -to 0 pm0_out_p ]
  set pm1_miso [ create_bd_port -dir I pm1_miso ]
  set pm1_out_n [ create_bd_port -dir O -from 9 -to 0 pm1_out_n ]
  set pm1_out_p [ create_bd_port -dir O -from 9 -to 0 pm1_out_p ]
  set pm2_miso [ create_bd_port -dir I pm2_miso ]
  set pm2_out_n [ create_bd_port -dir O -from 9 -to 0 pm2_out_n ]
  set pm2_out_p [ create_bd_port -dir O -from 9 -to 0 pm2_out_p ]
  set rstn_adc [ create_bd_port -dir O rstn_adc ]
  set rstn_pm [ create_bd_port -dir O rstn_pm ]
  set sclk_adc [ create_bd_port -dir O sclk_adc ]
  set sclk_pm0 [ create_bd_port -dir O sclk_pm0 ]
  set sclk_pm1 [ create_bd_port -dir O sclk_pm1 ]
  set sclk_pm2 [ create_bd_port -dir O sclk_pm2 ]
  set step [ create_bd_port -dir O -from 1 -to 0 step ]
  set up [ create_bd_port -dir O -from 7 -to 0 up ]

  # Create instance: adc_input, and set properties
  set adc_input [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz adc_input ]
  set_property -dict [ list \
   CONFIG.BUS_IO_STD {LVDS_25} \
   CONFIG.BUS_SIG_TYPE {DIFF} \
   CONFIG.CLK_FWD_IO_STD {LVDS_25} \
   CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_CLK_BUF {BUFIO} \
   CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
   CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SERIALIZATION_FACTOR {10} \
   CONFIG.SYSTEM_DATA_WIDTH {9} \
   CONFIG.USE_SERIALIZATION {true} \
 ] $adc_input

  # Create instance: all_rstn_sync_0, and set properties
  set block_name all_rstn_sync
  set block_cell_name all_rstn_sync_0
  if { [catch {set all_rstn_sync_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $all_rstn_sync_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /all_rstn_sync_0/sel_clk_rst]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] [get_bd_pins /all_rstn_sync_0/sel_io_rst]

  # Create instance: axi_mm2s_mapper_0, and set properties
  set axi_mm2s_mapper_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_mm2s_mapper axi_mm2s_mapper_0 ]
  set_property -dict [ list \
   CONFIG.ID_WIDTH {12} \
   CONFIG.INTERFACES {S_AXI} \
   CONFIG.TDATA_NUM_BYTES {2} \
 ] $axi_mm2s_mapper_0

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_0 ]
  set_property -dict [ list \
   CONFIG.CLKOUT1_DRIVES {BUFG} \
   CONFIG.CLKOUT1_JITTER {265.122} \
   CONFIG.CLKOUT1_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {10} \
   CONFIG.CLKOUT2_DRIVES {BUFG} \
   CONFIG.CLKOUT2_JITTER {265.122} \
   CONFIG.CLKOUT2_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {10} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {BUFG} \
   CONFIG.CLKOUT3_JITTER {134.634} \
   CONFIG.CLKOUT3_PHASE_ERROR {154.678} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {120.000} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_DRIVES {BUFG} \
   CONFIG.CLKOUT4_JITTER {98.767} \
   CONFIG.CLKOUT4_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT4_USED {false} \
   CONFIG.CLKOUT5_DRIVES {BUFG} \
   CONFIG.CLKOUT5_JITTER {127.801} \
   CONFIG.CLKOUT5_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT5_USED {false} \
   CONFIG.CLKOUT6_DRIVES {BUFG} \
   CONFIG.CLKOUT6_JITTER {112.035} \
   CONFIG.CLKOUT6_PHASE_ERROR {87.180} \
   CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT6_USED {false} \
   CONFIG.CLKOUT7_DRIVES {BUFG} \
   CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
   CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {24} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {120} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {120} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {10} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {1} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {1} \
   CONFIG.MMCM_CLKOUT5_DIVIDE {1} \
   CONFIG.MMCM_COMPENSATION {ZHOLD} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {3} \
   CONFIG.PRIMITIVE {PLL} \
   CONFIG.PRIM_SOURCE {No_buffer} \
   CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
   CONFIG.USE_PHASE_ALIGNMENT {false} \
   CONFIG.USE_RESET {true} \
 ] $clk_wiz_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {80.0} \
   CONFIG.CLKOUT1_DRIVES {BUFG} \
   CONFIG.CLKOUT1_JITTER {119.348} \
   CONFIG.CLKOUT1_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT1_REQUESTED_PHASE {45} \
   CONFIG.CLKOUT2_DRIVES {BUFG} \
   CONFIG.CLKOUT2_JITTER {119.348} \
   CONFIG.CLKOUT2_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT2_REQUESTED_PHASE {90} \
   CONFIG.CLKOUT2_USED {true} \
   CONFIG.CLKOUT3_DRIVES {BUFG} \
   CONFIG.CLKOUT3_JITTER {119.348} \
   CONFIG.CLKOUT3_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT3_REQUESTED_PHASE {135} \
   CONFIG.CLKOUT3_USED {true} \
   CONFIG.CLKOUT4_DRIVES {BUFG} \
   CONFIG.CLKOUT4_JITTER {119.348} \
   CONFIG.CLKOUT4_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT4_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT4_REQUESTED_PHASE {180} \
   CONFIG.CLKOUT4_USED {true} \
   CONFIG.CLKOUT5_DRIVES {BUFG} \
   CONFIG.CLKOUT5_JITTER {119.348} \
   CONFIG.CLKOUT5_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT5_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT5_REQUESTED_PHASE {225} \
   CONFIG.CLKOUT5_USED {true} \
   CONFIG.CLKOUT6_DRIVES {BUFG} \
   CONFIG.CLKOUT6_JITTER {119.348} \
   CONFIG.CLKOUT6_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT6_REQUESTED_PHASE {270} \
   CONFIG.CLKOUT6_USED {true} \
   CONFIG.CLKOUT7_DRIVES {BUFG} \
   CONFIG.CLKOUT7_JITTER {119.348} \
   CONFIG.CLKOUT7_PHASE_ERROR {96.948} \
   CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {125} \
   CONFIG.CLKOUT7_REQUESTED_PHASE {315} \
   CONFIG.CLKOUT7_USED {true} \
   CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
   CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {8.000} \
   CONFIG.MMCM_CLKIN1_PERIOD {8.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {8.000} \
   CONFIG.MMCM_CLKOUT0_PHASE {45.000} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT1_PHASE {90.000} \
   CONFIG.MMCM_CLKOUT2_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT2_PHASE {135.000} \
   CONFIG.MMCM_CLKOUT3_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT3_PHASE {180.000} \
   CONFIG.MMCM_CLKOUT4_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT4_PHASE {225.000} \
   CONFIG.MMCM_CLKOUT5_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT5_PHASE {270.000} \
   CONFIG.MMCM_CLKOUT6_DIVIDE {8} \
   CONFIG.MMCM_CLKOUT6_PHASE {315.000} \
   CONFIG.MMCM_COMPENSATION {ZHOLD} \
   CONFIG.MMCM_DIVCLK_DIVIDE {1} \
   CONFIG.NUM_OUT_CLKS {7} \
   CONFIG.PRIMITIVE {MMCM} \
   CONFIG.PRIM_IN_FREQ {125} \
   CONFIG.PRIM_SOURCE {Global_buffer} \
 ] $clk_wiz_1

  # Create instance: fft_top_2_0, and set properties
  set block_name fft_top_2
  set block_cell_name fft_top_2_0
  if { [catch {set fft_top_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $fft_top_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: galvo_top_0, and set properties
  set block_name galvo_top
  set block_cell_name galvo_top_0
  if { [catch {set galvo_top_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $galvo_top_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: input_top_2_0, and set properties
  set block_name input_top_2
  set block_cell_name input_top_2_0
  if { [catch {set input_top_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $input_top_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mc_top_0, and set properties
  set block_name mc_top
  set block_cell_name mc_top_0
  if { [catch {set mc_top_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mc_top_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: memaxi_reset, and set properties
  set memaxi_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset memaxi_reset ]

  # Create instance: mult_add_top_2_0, and set properties
  set block_name mult_add_top_2
  set block_cell_name mult_add_top_2_0
  if { [catch {set mult_add_top_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mult_add_top_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: peak_top_2_0, and set properties
  set block_name peak_top_2
  set block_cell_name peak_top_2_0
  if { [catch {set peak_top_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $peak_top_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_resets_0, and set properties
  set block_name pm_resets
  set block_cell_name pm_resets_0
  if { [catch {set pm_resets_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_resets_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_resets_1, and set properties
  set block_name pm_resets
  set block_cell_name pm_resets_1
  if { [catch {set pm_resets_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_resets_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_resets_2, and set properties
  set block_name pm_resets
  set block_cell_name pm_resets_2
  if { [catch {set pm_resets_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_resets_2 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_top_0, and set properties
  set block_name pm_top
  set block_cell_name pm_top_0
  if { [catch {set pm_top_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_top_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_top_1, and set properties
  set block_name pm_top
  set block_cell_name pm_top_1
  if { [catch {set pm_top_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_top_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pm_top_2, and set properties
  set block_name pm_top
  set block_cell_name pm_top_2
  if { [catch {set pm_top_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pm_top_2 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN0_PERIPHERAL_FREQMHZ {23.8095} \
   CONFIG.PCW_ACT_CAN1_PERIPHERAL_FREQMHZ {23.8095} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {125.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {50.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_I2C_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_ACT_USB1_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_APU_CLK_RATIO_ENABLE {6:2:1} \
   CONFIG.PCW_APU_PERIPHERAL_FREQMHZ {666.666666} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN0_BASEADDR {0xE0008000} \
   CONFIG.PCW_CAN0_GRP_CLK_ENABLE {0} \
   CONFIG.PCW_CAN0_HIGHADDR {0xE0008FFF} \
   CONFIG.PCW_CAN0_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_CAN0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_CAN0_PERIPHERAL_FREQMHZ {-1} \
   CONFIG.PCW_CAN1_BASEADDR {0xE0009000} \
   CONFIG.PCW_CAN1_GRP_CLK_ENABLE {0} \
   CONFIG.PCW_CAN1_HIGHADDR {0xE0009FFF} \
   CONFIG.PCW_CAN1_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_CAN1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_CAN1_PERIPHERAL_FREQMHZ {-1} \
   CONFIG.PCW_CAN_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_CAN_PERIPHERAL_VALID {0} \
   CONFIG.PCW_CLK0_FREQ {125000000} \
   CONFIG.PCW_CLK1_FREQ {50000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {200000000} \
   CONFIG.PCW_CORE0_FIQ_INTR {0} \
   CONFIG.PCW_CORE0_IRQ_INTR {0} \
   CONFIG.PCW_CORE1_FIQ_INTR {0} \
   CONFIG.PCW_CORE1_IRQ_INTR {0} \
   CONFIG.PCW_CPU_CPU_6X4X_MAX_RANGE {767} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_CLKSRC {ARM PLL} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_CRYSTAL_PERIPHERAL_FREQMHZ {33.333333} \
   CONFIG.PCW_DCI_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DCI_PERIPHERAL_FREQMHZ {10.159} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_HPRLPR_QUEUE_PARTITION {HPR(0)/LPR(32)} \
   CONFIG.PCW_DDR_HPR_TO_CRITICAL_PRIORITY_LEVEL {15} \
   CONFIG.PCW_DDR_LPR_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_DDR_PERIPHERAL_CLKSRC {DDR PLL} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_PORT0_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT1_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT2_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_PORT3_HPR_ENABLE {0} \
   CONFIG.PCW_DDR_RAM_BASEADDR {0x00100000} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x3FFFFFFF} \
   CONFIG.PCW_DDR_WRITE_TO_CRITICAL_PRIORITY_LEVEL {2} \
   CONFIG.PCW_DM_WIDTH {4} \
   CONFIG.PCW_DQS_WIDTH {4} \
   CONFIG.PCW_DQ_WIDTH {32} \
   CONFIG.PCW_ENET0_BASEADDR {0xE000B000} \
   CONFIG.PCW_ENET0_ENET0_IO {MIO 16 .. 27} \
   CONFIG.PCW_ENET0_GRP_MDIO_ENABLE {1} \
   CONFIG.PCW_ENET0_GRP_MDIO_IO {MIO 52 .. 53} \
   CONFIG.PCW_ENET0_HIGHADDR {0xE000BFFF} \
   CONFIG.PCW_ENET0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET0_RESET_ENABLE {1} \
   CONFIG.PCW_ENET0_RESET_IO {MIO 50} \
   CONFIG.PCW_ENET1_BASEADDR {0xE000C000} \
   CONFIG.PCW_ENET1_GRP_MDIO_ENABLE {0} \
   CONFIG.PCW_ENET1_HIGHADDR {0xE000CFFF} \
   CONFIG.PCW_ENET1_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_FREQMHZ {1000 Mbps} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {1} \
   CONFIG.PCW_ENET_RESET_POLARITY {Active Low} \
   CONFIG.PCW_ENET_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_EN_4K_TIMER {0} \
   CONFIG.PCW_EN_CAN0 {0} \
   CONFIG.PCW_EN_CAN1 {0} \
   CONFIG.PCW_EN_CLK0_PORT {1} \
   CONFIG.PCW_EN_CLK1_PORT {1} \
   CONFIG.PCW_EN_CLK2_PORT {1} \
   CONFIG.PCW_EN_CLK3_PORT {1} \
   CONFIG.PCW_EN_CLKTRIG0_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG1_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG2_PORT {0} \
   CONFIG.PCW_EN_CLKTRIG3_PORT {0} \
   CONFIG.PCW_EN_DDR {1} \
   CONFIG.PCW_EN_EMIO_CAN0 {0} \
   CONFIG.PCW_EN_EMIO_CAN1 {0} \
   CONFIG.PCW_EN_EMIO_CD_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_CD_SDIO1 {0} \
   CONFIG.PCW_EN_EMIO_ENET0 {0} \
   CONFIG.PCW_EN_EMIO_ENET1 {0} \
   CONFIG.PCW_EN_EMIO_GPIO {0} \
   CONFIG.PCW_EN_EMIO_I2C0 {0} \
   CONFIG.PCW_EN_EMIO_I2C1 {0} \
   CONFIG.PCW_EN_EMIO_MODEM_UART0 {0} \
   CONFIG.PCW_EN_EMIO_MODEM_UART1 {0} \
   CONFIG.PCW_EN_EMIO_PJTAG {0} \
   CONFIG.PCW_EN_EMIO_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_SDIO1 {0} \
   CONFIG.PCW_EN_EMIO_SPI0 {0} \
   CONFIG.PCW_EN_EMIO_SPI1 {0} \
   CONFIG.PCW_EN_EMIO_SRAM_INT {0} \
   CONFIG.PCW_EN_EMIO_TRACE {0} \
   CONFIG.PCW_EN_EMIO_TTC0 {1} \
   CONFIG.PCW_EN_EMIO_TTC1 {1} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_EMIO_UART1 {0} \
   CONFIG.PCW_EN_EMIO_WDT {1} \
   CONFIG.PCW_EN_EMIO_WP_SDIO0 {0} \
   CONFIG.PCW_EN_EMIO_WP_SDIO1 {0} \
   CONFIG.PCW_EN_ENET0 {1} \
   CONFIG.PCW_EN_ENET1 {0} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_I2C0 {0} \
   CONFIG.PCW_EN_I2C1 {1} \
   CONFIG.PCW_EN_MODEM_UART0 {0} \
   CONFIG.PCW_EN_MODEM_UART1 {0} \
   CONFIG.PCW_EN_PJTAG {0} \
   CONFIG.PCW_EN_PTP_ENET0 {0} \
   CONFIG.PCW_EN_PTP_ENET1 {0} \
   CONFIG.PCW_EN_QSPI {1} \
   CONFIG.PCW_EN_RST0_PORT {1} \
   CONFIG.PCW_EN_RST1_PORT {0} \
   CONFIG.PCW_EN_RST2_PORT {0} \
   CONFIG.PCW_EN_RST3_PORT {0} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_SDIO1 {0} \
   CONFIG.PCW_EN_SMC {0} \
   CONFIG.PCW_EN_SPI0 {0} \
   CONFIG.PCW_EN_SPI1 {0} \
   CONFIG.PCW_EN_TRACE {0} \
   CONFIG.PCW_EN_TTC0 {1} \
   CONFIG.PCW_EN_TTC1 {1} \
   CONFIG.PCW_EN_UART0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_EN_USB0 {1} \
   CONFIG.PCW_EN_USB1 {0} \
   CONFIG.PCW_EN_WDT {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {4} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {2} \
   CONFIG.PCW_FCLK1_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {4} \
   CONFIG.PCW_FCLK2_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {10} \
   CONFIG.PCW_FCLK3_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK_CLK0_BUF {TRUE} \
   CONFIG.PCW_FCLK_CLK1_BUF {TRUE} \
   CONFIG.PCW_FCLK_CLK2_BUF {TRUE} \
   CONFIG.PCW_FCLK_CLK3_BUF {TRUE} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {125} \
   CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_FPGA2_PERIPHERAL_FREQMHZ {10} \
   CONFIG.PCW_FPGA3_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {1} \
   CONFIG.PCW_GP0_EN_MODIFIABLE_TXN {1} \
   CONFIG.PCW_GP0_NUM_READ_THREADS {4} \
   CONFIG.PCW_GP0_NUM_WRITE_THREADS {4} \
   CONFIG.PCW_GP1_EN_MODIFIABLE_TXN {1} \
   CONFIG.PCW_GP1_NUM_READ_THREADS {4} \
   CONFIG.PCW_GP1_NUM_WRITE_THREADS {4} \
   CONFIG.PCW_GPIO_BASEADDR {0xE000A000} \
   CONFIG.PCW_GPIO_EMIO_GPIO_ENABLE {0} \
   CONFIG.PCW_GPIO_EMIO_GPIO_IO {<Select>} \
   CONFIG.PCW_GPIO_EMIO_GPIO_WIDTH {64} \
   CONFIG.PCW_GPIO_HIGHADDR {0xE000AFFF} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_GPIO_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_BASEADDR {0xE0004000} \
   CONFIG.PCW_I2C0_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C0_HIGHADDR {0xE0004FFF} \
   CONFIG.PCW_I2C0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_BASEADDR {0xE0005000} \
   CONFIG.PCW_I2C1_GRP_INT_ENABLE {0} \
   CONFIG.PCW_I2C1_HIGHADDR {0xE0005FFF} \
   CONFIG.PCW_I2C1_I2C1_IO {MIO 48 .. 49} \
   CONFIG.PCW_I2C1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_I2C_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_RESET_POLARITY {Active Low} \
   CONFIG.PCW_IMPORT_BOARD_PRESET {None} \
   CONFIG.PCW_INCLUDE_ACP_TRANS_CHECK {0} \
   CONFIG.PCW_INCLUDE_TRACE_BUFFER {0} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {30} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1000.000} \
   CONFIG.PCW_IRQ_F2P_INTR {0} \
   CONFIG.PCW_IRQ_F2P_MODE {DIRECT} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {out} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {in} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {in} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {out} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {out} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_16_PULLUP {enabled} \
   CONFIG.PCW_MIO_16_SLEW {slow} \
   CONFIG.PCW_MIO_17_DIRECTION {out} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_17_PULLUP {enabled} \
   CONFIG.PCW_MIO_17_SLEW {slow} \
   CONFIG.PCW_MIO_18_DIRECTION {out} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_18_PULLUP {enabled} \
   CONFIG.PCW_MIO_18_SLEW {slow} \
   CONFIG.PCW_MIO_19_DIRECTION {out} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_19_PULLUP {enabled} \
   CONFIG.PCW_MIO_19_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {out} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {out} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_20_PULLUP {enabled} \
   CONFIG.PCW_MIO_20_SLEW {slow} \
   CONFIG.PCW_MIO_21_DIRECTION {out} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_21_PULLUP {enabled} \
   CONFIG.PCW_MIO_21_SLEW {slow} \
   CONFIG.PCW_MIO_22_DIRECTION {in} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_22_PULLUP {enabled} \
   CONFIG.PCW_MIO_22_SLEW {slow} \
   CONFIG.PCW_MIO_23_DIRECTION {in} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_23_PULLUP {enabled} \
   CONFIG.PCW_MIO_23_SLEW {slow} \
   CONFIG.PCW_MIO_24_DIRECTION {in} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_24_PULLUP {enabled} \
   CONFIG.PCW_MIO_24_SLEW {slow} \
   CONFIG.PCW_MIO_25_DIRECTION {in} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_25_PULLUP {enabled} \
   CONFIG.PCW_MIO_25_SLEW {slow} \
   CONFIG.PCW_MIO_26_DIRECTION {in} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_26_PULLUP {enabled} \
   CONFIG.PCW_MIO_26_SLEW {slow} \
   CONFIG.PCW_MIO_27_DIRECTION {in} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_27_PULLUP {enabled} \
   CONFIG.PCW_MIO_27_SLEW {slow} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {slow} \
   CONFIG.PCW_MIO_29_DIRECTION {in} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {out} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {slow} \
   CONFIG.PCW_MIO_31_DIRECTION {in} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {slow} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {slow} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {slow} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {slow} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {slow} \
   CONFIG.PCW_MIO_36_DIRECTION {in} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {slow} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {slow} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {slow} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_40_PULLUP {disabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_41_PULLUP {disabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_42_PULLUP {disabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_43_PULLUP {disabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_44_PULLUP {disabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_45_PULLUP {disabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {inout} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {inout} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {inout} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {inout} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {out} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {out} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {out} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 1.8V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {out} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {inout} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_PRIMITIVE {54} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {\
GPIO#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI\
Flash#Quad SPI Flash#GPIO#Quad SPI Flash#GPIO#GPIO#GPIO#UART 1#UART 1#UART\
0#UART 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet\
0#Enet 0#Enet 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB\
0#USB 0#SD 0#SD 0#SD 0#SD 0#SD 0#SD 0#GPIO#GPIO#I2C 1#I2C 1#ENET Reset#USB\
Reset#Enet 0#Enet 0} \
   CONFIG.PCW_MIO_TREE_SIGNALS {\
gpio[0]#qspi0_ss_b#qspi0_io[0]#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]/HOLD_B#qspi0_sclk#gpio[7]#qspi_fbclk#gpio[9]#gpio[10]#gpio[11]#tx#rx#rx#tx#tx_clk#txd[0]#txd[1]#txd[2]#txd[3]#tx_ctl#rx_clk#rxd[0]#rxd[1]#rxd[2]#rxd[3]#rx_ctl#data[4]#dir#stp#nxt#data[0]#data[1]#data[2]#data[3]#clk#data[5]#data[6]#data[7]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#gpio[47]#scl#sda#reset#reset#mdc#mdio} \
   CONFIG.PCW_M_AXI_GP0_ENABLE_STATIC_REMAP {0} \
   CONFIG.PCW_M_AXI_GP0_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP0_SUPPORT_NARROW_BURST {0} \
   CONFIG.PCW_M_AXI_GP0_THREAD_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP1_ENABLE_STATIC_REMAP {0} \
   CONFIG.PCW_M_AXI_GP1_ID_WIDTH {12} \
   CONFIG.PCW_M_AXI_GP1_SUPPORT_NARROW_BURST {0} \
   CONFIG.PCW_M_AXI_GP1_THREAD_ID_WIDTH {12} \
   CONFIG.PCW_NAND_CYCLES_T_AR {1} \
   CONFIG.PCW_NAND_CYCLES_T_CLR {1} \
   CONFIG.PCW_NAND_CYCLES_T_RC {11} \
   CONFIG.PCW_NAND_CYCLES_T_REA {1} \
   CONFIG.PCW_NAND_CYCLES_T_RR {1} \
   CONFIG.PCW_NAND_CYCLES_T_WC {11} \
   CONFIG.PCW_NAND_CYCLES_T_WP {1} \
   CONFIG.PCW_NAND_GRP_D8_ENABLE {0} \
   CONFIG.PCW_NAND_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_CS0_T_CEOE {1} \
   CONFIG.PCW_NOR_CS0_T_PC {1} \
   CONFIG.PCW_NOR_CS0_T_RC {11} \
   CONFIG.PCW_NOR_CS0_T_TR {1} \
   CONFIG.PCW_NOR_CS0_T_WC {11} \
   CONFIG.PCW_NOR_CS0_T_WP {1} \
   CONFIG.PCW_NOR_CS0_WE_TIME {0} \
   CONFIG.PCW_NOR_CS1_T_CEOE {1} \
   CONFIG.PCW_NOR_CS1_T_PC {1} \
   CONFIG.PCW_NOR_CS1_T_RC {11} \
   CONFIG.PCW_NOR_CS1_T_TR {1} \
   CONFIG.PCW_NOR_CS1_T_WC {11} \
   CONFIG.PCW_NOR_CS1_T_WP {1} \
   CONFIG.PCW_NOR_CS1_WE_TIME {0} \
   CONFIG.PCW_NOR_GRP_A25_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS0_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_CS1_ENABLE {0} \
   CONFIG.PCW_NOR_GRP_SRAM_INT_ENABLE {0} \
   CONFIG.PCW_NOR_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_NOR_SRAM_CS0_T_CEOE {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_PC {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_RC {11} \
   CONFIG.PCW_NOR_SRAM_CS0_T_TR {1} \
   CONFIG.PCW_NOR_SRAM_CS0_T_WC {11} \
   CONFIG.PCW_NOR_SRAM_CS0_T_WP {1} \
   CONFIG.PCW_NOR_SRAM_CS0_WE_TIME {0} \
   CONFIG.PCW_NOR_SRAM_CS1_T_CEOE {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_PC {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_RC {11} \
   CONFIG.PCW_NOR_SRAM_CS1_T_TR {1} \
   CONFIG.PCW_NOR_SRAM_CS1_T_WC {11} \
   CONFIG.PCW_NOR_SRAM_CS1_T_WP {1} \
   CONFIG.PCW_NOR_SRAM_CS1_WE_TIME {0} \
   CONFIG.PCW_OVERRIDE_BASIC_CLOCK {0} \
   CONFIG.PCW_P2F_CAN0_INTR {0} \
   CONFIG.PCW_P2F_CAN1_INTR {0} \
   CONFIG.PCW_P2F_CTI_INTR {0} \
   CONFIG.PCW_P2F_DMAC0_INTR {0} \
   CONFIG.PCW_P2F_DMAC1_INTR {0} \
   CONFIG.PCW_P2F_DMAC2_INTR {0} \
   CONFIG.PCW_P2F_DMAC3_INTR {0} \
   CONFIG.PCW_P2F_DMAC4_INTR {0} \
   CONFIG.PCW_P2F_DMAC5_INTR {0} \
   CONFIG.PCW_P2F_DMAC6_INTR {0} \
   CONFIG.PCW_P2F_DMAC7_INTR {0} \
   CONFIG.PCW_P2F_DMAC_ABORT_INTR {0} \
   CONFIG.PCW_P2F_ENET0_INTR {0} \
   CONFIG.PCW_P2F_ENET1_INTR {0} \
   CONFIG.PCW_P2F_GPIO_INTR {0} \
   CONFIG.PCW_P2F_I2C0_INTR {0} \
   CONFIG.PCW_P2F_I2C1_INTR {0} \
   CONFIG.PCW_P2F_QSPI_INTR {0} \
   CONFIG.PCW_P2F_SDIO0_INTR {0} \
   CONFIG.PCW_P2F_SDIO1_INTR {0} \
   CONFIG.PCW_P2F_SMC_INTR {0} \
   CONFIG.PCW_P2F_SPI0_INTR {0} \
   CONFIG.PCW_P2F_SPI1_INTR {0} \
   CONFIG.PCW_P2F_UART0_INTR {0} \
   CONFIG.PCW_P2F_UART1_INTR {0} \
   CONFIG.PCW_P2F_USB0_INTR {0} \
   CONFIG.PCW_P2F_USB1_INTR {0} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY0 {0.075} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY1 {0.070} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY2 {0.077} \
   CONFIG.PCW_PACKAGE_DDR_BOARD_DELAY3 {0.094} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_0 {-0.000} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_1 {-0.001} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_2 {0.004} \
   CONFIG.PCW_PACKAGE_DDR_DQS_TO_CLK_DELAY_3 {-0.035} \
   CONFIG.PCW_PACKAGE_NAME {clg485} \
   CONFIG.PCW_PCAP_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_PCAP_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_PERIPHERAL_BOARD_PRESET {part0} \
   CONFIG.PCW_PJTAG_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_PLL_BYPASSMODE_ENABLE {0} \
   CONFIG.PCW_PRESET_BANK0_VOLTAGE {LVCMOS 3.3V} \
   CONFIG.PCW_PRESET_BANK1_VOLTAGE {LVCMOS 1.8V} \
   CONFIG.PCW_PS7_SI_REV {PRODUCTION} \
   CONFIG.PCW_QSPI_GRP_FBCLK_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_FBCLK_IO {MIO 8} \
   CONFIG.PCW_QSPI_GRP_IO1_ENABLE {0} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_ENABLE {1} \
   CONFIG.PCW_QSPI_GRP_SINGLE_SS_IO {MIO 1 .. 6} \
   CONFIG.PCW_QSPI_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_QSPI_INTERNAL_HIGHADDRESS {0xFCFFFFFF} \
   CONFIG.PCW_QSPI_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {5} \
   CONFIG.PCW_QSPI_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_QSPI_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_QSPI_QSPI_IO {MIO 1 .. 6} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SD1_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD1_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD1_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SDIO0_BASEADDR {0xE0100000} \
   CONFIG.PCW_SDIO0_HIGHADDR {0xE0100FFF} \
   CONFIG.PCW_SDIO1_BASEADDR {0xE0101000} \
   CONFIG.PCW_SDIO1_HIGHADDR {0xE0101FFF} \
   CONFIG.PCW_SDIO_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SINGLE_QSPI_DATA_MODE {x4} \
   CONFIG.PCW_SMC_CYCLE_T0 {NA} \
   CONFIG.PCW_SMC_CYCLE_T1 {NA} \
   CONFIG.PCW_SMC_CYCLE_T2 {NA} \
   CONFIG.PCW_SMC_CYCLE_T3 {NA} \
   CONFIG.PCW_SMC_CYCLE_T4 {NA} \
   CONFIG.PCW_SMC_CYCLE_T5 {NA} \
   CONFIG.PCW_SMC_CYCLE_T6 {NA} \
   CONFIG.PCW_SMC_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SMC_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SMC_PERIPHERAL_VALID {0} \
   CONFIG.PCW_SPI0_BASEADDR {0xE0006000} \
   CONFIG.PCW_SPI0_GRP_SS0_ENABLE {0} \
   CONFIG.PCW_SPI0_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_SPI0_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI0_HIGHADDR {0xE0006FFF} \
   CONFIG.PCW_SPI0_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SPI1_BASEADDR {0xE0007000} \
   CONFIG.PCW_SPI1_GRP_SS0_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS1_ENABLE {0} \
   CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI1_HIGHADDR {0xE0007FFF} \
   CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_SPI_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {166.666666} \
   CONFIG.PCW_SPI_PERIPHERAL_VALID {0} \
   CONFIG.PCW_S_AXI_ACP_ARUSER_VAL {31} \
   CONFIG.PCW_S_AXI_ACP_AWUSER_VAL {31} \
   CONFIG.PCW_S_AXI_ACP_ID_WIDTH {3} \
   CONFIG.PCW_S_AXI_GP0_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_GP1_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP0_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP0_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP1_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP1_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP2_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP2_ID_WIDTH {6} \
   CONFIG.PCW_S_AXI_HP3_DATA_WIDTH {64} \
   CONFIG.PCW_S_AXI_HP3_ID_WIDTH {6} \
   CONFIG.PCW_TPIU_PERIPHERAL_CLKSRC {External} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_FREQMHZ {200} \
   CONFIG.PCW_TRACE_BUFFER_CLOCK_DELAY {12} \
   CONFIG.PCW_TRACE_BUFFER_FIFO_SIZE {128} \
   CONFIG.PCW_TRACE_GRP_16BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_2BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_32BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_4BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_GRP_8BIT_ENABLE {0} \
   CONFIG.PCW_TRACE_INTERNAL_WIDTH {2} \
   CONFIG.PCW_TRACE_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_TRACE_PIPELINE_WIDTH {8} \
   CONFIG.PCW_TTC0_BASEADDR {0xE0104000} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC0_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC0_HIGHADDR {0xE0104fff} \
   CONFIG.PCW_TTC0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_TTC0_TTC0_IO {EMIO} \
   CONFIG.PCW_TTC1_BASEADDR {0xE0105000} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK0_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK1_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_TTC1_CLK2_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_TTC1_HIGHADDR {0xE0105fff} \
   CONFIG.PCW_TTC1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_TTC1_TTC1_IO {EMIO} \
   CONFIG.PCW_TTC_PERIPHERAL_FREQMHZ {50} \
   CONFIG.PCW_UART0_BASEADDR {0xE0000000} \
   CONFIG.PCW_UART0_BAUD_RATE {115200} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_HIGHADDR {0xE0000FFF} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
   CONFIG.PCW_UART1_BASEADDR {0xE0001000} \
   CONFIG.PCW_UART1_BAUD_RATE {115200} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_HIGHADDR {0xE0001FFF} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 12 .. 13} \
   CONFIG.PCW_UART_PERIPHERAL_CLKSRC {IO PLL} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_ADV_ENABLE {0} \
   CONFIG.PCW_UIPARAM_DDR_AL {0} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BL {8} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.25} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.25} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.25} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.25} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {32 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PACKAGE_LENGTH {76.428} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PACKAGE_LENGTH {76.428} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PACKAGE_LENGTH {76.428} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PACKAGE_LENGTH {76.428} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_CLOCK_STOP_EN {0} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PACKAGE_LENGTH {76.687} \
   CONFIG.PCW_UIPARAM_DDR_DQS_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PACKAGE_LENGTH {77.8025} \
   CONFIG.PCW_UIPARAM_DDR_DQS_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PACKAGE_LENGTH {72.8405} \
   CONFIG.PCW_UIPARAM_DDR_DQS_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PACKAGE_LENGTH {111.904} \
   CONFIG.PCW_UIPARAM_DDR_DQS_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_2 {0.0} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_3 {0.0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PACKAGE_LENGTH {73.119} \
   CONFIG.PCW_UIPARAM_DDR_DQ_0_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PACKAGE_LENGTH {63.8935} \
   CONFIG.PCW_UIPARAM_DDR_DQ_1_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PACKAGE_LENGTH {77.045} \
   CONFIG.PCW_UIPARAM_DDR_DQ_2_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_LENGTH_MM {0} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PACKAGE_LENGTH {111.903} \
   CONFIG.PCW_UIPARAM_DDR_DQ_3_PROPOGATION_DELAY {160} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_ENABLE {1} \
   CONFIG.PCW_UIPARAM_DDR_FREQ_MHZ {533.333333} \
   CONFIG.PCW_UIPARAM_DDR_HIGH_TEMP {Normal (0-85)} \
   CONFIG.PCW_UIPARAM_DDR_MEMORY_TYPE {DDR 3 (Low Voltage)} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {MT41J256M16 RE-125} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1066F} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_DATA_EYE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_READ_GATE {1} \
   CONFIG.PCW_UIPARAM_DDR_TRAIN_WRITE_LEVEL {1} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {40.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35.0} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.91} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_UIPARAM_DDR_USE_INTERNAL_VREF {0} \
   CONFIG.PCW_UIPARAM_GENERATE_SUMMARY {NA} \
   CONFIG.PCW_USB0_BASEADDR {0xE0102000} \
   CONFIG.PCW_USB0_HIGHADDR {0xE0102fff} \
   CONFIG.PCW_USB0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_USB0_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB0_RESET_ENABLE {1} \
   CONFIG.PCW_USB0_RESET_IO {MIO 51} \
   CONFIG.PCW_USB0_USB0_IO {MIO 28 .. 39} \
   CONFIG.PCW_USB1_BASEADDR {0xE0103000} \
   CONFIG.PCW_USB1_HIGHADDR {0xE0103fff} \
   CONFIG.PCW_USB1_PERIPHERAL_ENABLE {0} \
   CONFIG.PCW_USB1_PERIPHERAL_FREQMHZ {60} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USB_RESET_POLARITY {Active Low} \
   CONFIG.PCW_USB_RESET_SELECT {Share reset pin} \
   CONFIG.PCW_USE_AXI_FABRIC_IDLE {0} \
   CONFIG.PCW_USE_AXI_NONSECURE {0} \
   CONFIG.PCW_USE_CORESIGHT {0} \
   CONFIG.PCW_USE_CROSS_TRIGGER {0} \
   CONFIG.PCW_USE_CR_FABRIC {1} \
   CONFIG.PCW_USE_DDR_BYPASS {0} \
   CONFIG.PCW_USE_DEBUG {0} \
   CONFIG.PCW_USE_DEFAULT_ACP_USER_VAL {0} \
   CONFIG.PCW_USE_DMA0 {0} \
   CONFIG.PCW_USE_DMA1 {0} \
   CONFIG.PCW_USE_DMA2 {0} \
   CONFIG.PCW_USE_DMA3 {0} \
   CONFIG.PCW_USE_EXPANDED_IOP {0} \
   CONFIG.PCW_USE_EXPANDED_PS_SLCR_REGISTERS {0} \
   CONFIG.PCW_USE_FABRIC_INTERRUPT {0} \
   CONFIG.PCW_USE_HIGH_OCM {0} \
   CONFIG.PCW_USE_M_AXI_GP0 {1} \
   CONFIG.PCW_USE_M_AXI_GP1 {1} \
   CONFIG.PCW_USE_PROC_EVENT_BUS {0} \
   CONFIG.PCW_USE_PS_SLCR_REGISTERS {0} \
   CONFIG.PCW_USE_S_AXI_ACP {0} \
   CONFIG.PCW_USE_S_AXI_GP0 {0} \
   CONFIG.PCW_USE_S_AXI_GP1 {0} \
   CONFIG.PCW_USE_S_AXI_HP0 {0} \
   CONFIG.PCW_USE_S_AXI_HP1 {0} \
   CONFIG.PCW_USE_S_AXI_HP2 {0} \
   CONFIG.PCW_USE_S_AXI_HP3 {0} \
   CONFIG.PCW_USE_TRACE {0} \
   CONFIG.PCW_USE_TRACE_DATA_EDGE_DETECTOR {0} \
   CONFIG.PCW_VALUE_SILVERSION {3} \
   CONFIG.PCW_WDT_PERIPHERAL_CLKSRC {CPU_1X} \
   CONFIG.PCW_WDT_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_WDT_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_WDT_PERIPHERAL_FREQMHZ {133.333333} \
   CONFIG.PCW_WDT_WDT_IO {EMIO} \
 ] $processing_system7_0

  # Create instance: ps7_0_axi_periph, and set properties
  set ps7_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect ps7_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $ps7_0_axi_periph

  # Create instance: regs_0, and set properties
  set block_name regs
  set block_cell_name regs_0
  if { [catch {set regs_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $regs_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: rst_ps7_0_200M, and set properties
  set rst_ps7_0_200M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_ps7_0_200M ]

  # Create instance: selectio_pm0, and set properties
  set selectio_pm0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz selectio_pm0 ]
  set_property -dict [ list \
   CONFIG.BUS_DIR {OUTPUTS} \
   CONFIG.BUS_IO_STD {LVDS_25} \
   CONFIG.BUS_SIG_TYPE {DIFF} \
   CONFIG.CLK_FWD {true} \
   CONFIG.CLK_FWD_IO_STD {LVDS_25} \
   CONFIG.CLK_FWD_SER {false} \
   CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
   CONFIG.CONFIG_CLK_FWD {true} \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_BUS_IN_DELAY {NONE} \
   CONFIG.SELIO_CLK_BUF {MMCM} \
   CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
   CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SELIO_ODDR_ALIGNMENT {OPPOSITE_EDGE} \
   CONFIG.SERIALIZATION_FACTOR {4} \
   CONFIG.SYSTEM_DATA_WIDTH {10} \
   CONFIG.USE_SERIALIZATION {false} \
 ] $selectio_pm0

  # Create instance: selectio_pm1, and set properties
  set selectio_pm1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz selectio_pm1 ]
  set_property -dict [ list \
   CONFIG.BUS_DIR {OUTPUTS} \
   CONFIG.BUS_IO_STD {LVDS_25} \
   CONFIG.BUS_SIG_TYPE {DIFF} \
   CONFIG.CLK_FWD {true} \
   CONFIG.CLK_FWD_IO_STD {LVDS_25} \
   CONFIG.CLK_FWD_SER {false} \
   CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
   CONFIG.CONFIG_CLK_FWD {true} \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_BUS_IN_DELAY {NONE} \
   CONFIG.SELIO_CLK_BUF {MMCM} \
   CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
   CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SELIO_ODDR_ALIGNMENT {OPPOSITE_EDGE} \
   CONFIG.SERIALIZATION_FACTOR {4} \
   CONFIG.SYSTEM_DATA_WIDTH {10} \
   CONFIG.USE_SERIALIZATION {false} \
 ] $selectio_pm1

  # Create instance: selectio_pm2, and set properties
  set selectio_pm2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:selectio_wiz selectio_pm2 ]
  set_property -dict [ list \
   CONFIG.BUS_DIR {OUTPUTS} \
   CONFIG.BUS_IO_STD {LVDS_25} \
   CONFIG.BUS_SIG_TYPE {DIFF} \
   CONFIG.CLK_FWD {true} \
   CONFIG.CLK_FWD_IO_STD {LVDS_25} \
   CONFIG.CLK_FWD_SER {false} \
   CONFIG.CLK_FWD_SIG_TYPE {DIFF} \
   CONFIG.CONFIG_CLK_FWD {true} \
   CONFIG.SELIO_ACTIVE_EDGE {DDR} \
   CONFIG.SELIO_BUS_IN_DELAY {NONE} \
   CONFIG.SELIO_CLK_BUF {MMCM} \
   CONFIG.SELIO_CLK_IO_STD {LVDS_25} \
   CONFIG.SELIO_CLK_SIG_TYPE {DIFF} \
   CONFIG.SELIO_INTERFACE_TYPE {NETWORKING} \
   CONFIG.SELIO_ODDR_ALIGNMENT {OPPOSITE_EDGE} \
   CONFIG.SERIALIZATION_FACTOR {4} \
   CONFIG.SYSTEM_DATA_WIDTH {10} \
   CONFIG.USE_SERIALIZATION {false} \
 ] $selectio_pm2

  # Create instance: spi_adc_pm_0, and set properties
  set block_name spi_adc_pm
  set block_cell_name spi_adc_pm_0
  if { [catch {set spi_adc_pm_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $spi_adc_pm_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: vga_0, and set properties
  set block_name vga
  set block_cell_name vga_0
  if { [catch {set vga_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $vga_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: window_top_2_0, and set properties
  set block_name window_top_2
  set block_cell_name window_top_2_0
  if { [catch {set window_top_2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $window_top_2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {8} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_3, and set properties
  set xlconstant_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_3 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {32} \
 ] $xlconstant_3

  # Create instance: xlslice_0, and set properties
  set xlslice_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_0 ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {9} \
 ] $xlslice_0

  # Create instance: xlslice_1, and set properties
  set xlslice_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_1 ]
  set_property -dict [ list \
   CONFIG.DIN_WIDTH {3} \
 ] $xlslice_1

  # Create instance: xlslice_2, and set properties
  set xlslice_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_2 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {2} \
   CONFIG.DIN_TO {2} \
   CONFIG.DIN_WIDTH {3} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_2

  # Create instance: xlslice_3, and set properties
  set xlslice_3 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_3 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {1} \
   CONFIG.DIN_TO {1} \
   CONFIG.DIN_WIDTH {3} \
   CONFIG.DOUT_WIDTH {1} \
 ] $xlslice_3

  # Create instance: xlslice_4, and set properties
  set xlslice_4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice xlslice_4 ]
  set_property -dict [ list \
   CONFIG.DIN_FROM {7} \
   CONFIG.DIN_TO {0} \
   CONFIG.DIN_WIDTH {10} \
   CONFIG.DOUT_WIDTH {8} \
 ] $xlslice_4

  # Create instance: xmux, and set properties
  set xmux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect xmux ]
  set_property -dict [ list \
   CONFIG.NUM_MI {15} \
 ] $xmux

  # Create interface connections
  connect_bd_intf_net -intf_net diff_clk_in_1_1 [get_bd_intf_ports adc_clk] [get_bd_intf_pins adc_input/diff_clk_in]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data0 [get_bd_intf_pins fft_top_2_0/m_axis_data0] [get_bd_intf_pins mult_add_top_2_0/s_axis_data0]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data1 [get_bd_intf_pins fft_top_2_0/m_axis_data1] [get_bd_intf_pins mult_add_top_2_0/s_axis_data1]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data2 [get_bd_intf_pins fft_top_2_0/m_axis_data2] [get_bd_intf_pins mult_add_top_2_0/s_axis_data2]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data3 [get_bd_intf_pins fft_top_2_0/m_axis_data3] [get_bd_intf_pins mult_add_top_2_0/s_axis_data3]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data4 [get_bd_intf_pins fft_top_2_0/m_axis_data4] [get_bd_intf_pins mult_add_top_2_0/s_axis_data4]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data5 [get_bd_intf_pins fft_top_2_0/m_axis_data5] [get_bd_intf_pins mult_add_top_2_0/s_axis_data5]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data6 [get_bd_intf_pins fft_top_2_0/m_axis_data6] [get_bd_intf_pins mult_add_top_2_0/s_axis_data6]
  connect_bd_intf_net -intf_net fft_top_2_0_m_axis_data7 [get_bd_intf_pins fft_top_2_0/m_axis_data7] [get_bd_intf_pins mult_add_top_2_0/s_axis_data7]
  connect_bd_intf_net -intf_net input_top_2_0_M_AXIS [get_bd_intf_pins input_top_2_0/M_AXIS] [get_bd_intf_pins window_top_2_0/S_AXIS]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data0 [get_bd_intf_pins fft_top_2_0/s_axis_data0] [get_bd_intf_pins input_top_2_0/m_axis_data0]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data1 [get_bd_intf_pins fft_top_2_0/s_axis_data1] [get_bd_intf_pins input_top_2_0/m_axis_data1]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data2 [get_bd_intf_pins fft_top_2_0/s_axis_data2] [get_bd_intf_pins input_top_2_0/m_axis_data2]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data3 [get_bd_intf_pins fft_top_2_0/s_axis_data3] [get_bd_intf_pins input_top_2_0/m_axis_data3]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data4 [get_bd_intf_pins fft_top_2_0/s_axis_data4] [get_bd_intf_pins input_top_2_0/m_axis_data4]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data5 [get_bd_intf_pins fft_top_2_0/s_axis_data5] [get_bd_intf_pins input_top_2_0/m_axis_data5]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data6 [get_bd_intf_pins fft_top_2_0/s_axis_data6] [get_bd_intf_pins input_top_2_0/m_axis_data6]
  connect_bd_intf_net -intf_net input_top_2_0_m_axis_data7 [get_bd_intf_pins fft_top_2_0/s_axis_data7] [get_bd_intf_pins input_top_2_0/m_axis_data7]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data0 [get_bd_intf_pins mult_add_top_2_0/m_axis_data0] [get_bd_intf_pins peak_top_2_0/s_axis_data0]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data1 [get_bd_intf_pins mult_add_top_2_0/m_axis_data1] [get_bd_intf_pins peak_top_2_0/s_axis_data1]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data2 [get_bd_intf_pins mult_add_top_2_0/m_axis_data2] [get_bd_intf_pins peak_top_2_0/s_axis_data2]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data3 [get_bd_intf_pins mult_add_top_2_0/m_axis_data3] [get_bd_intf_pins peak_top_2_0/s_axis_data3]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data4 [get_bd_intf_pins mult_add_top_2_0/m_axis_data4] [get_bd_intf_pins peak_top_2_0/s_axis_data4]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data5 [get_bd_intf_pins mult_add_top_2_0/m_axis_data5] [get_bd_intf_pins peak_top_2_0/s_axis_data5]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data6 [get_bd_intf_pins mult_add_top_2_0/m_axis_data6] [get_bd_intf_pins peak_top_2_0/s_axis_data6]
  connect_bd_intf_net -intf_net mult_add_top_2_0_m_axis_data7 [get_bd_intf_pins mult_add_top_2_0/m_axis_data7] [get_bd_intf_pins peak_top_2_0/s_axis_data7]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP0 [get_bd_intf_pins processing_system7_0/M_AXI_GP0] [get_bd_intf_pins xmux/S00_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_M_AXI_GP1 [get_bd_intf_pins processing_system7_0/M_AXI_GP1] [get_bd_intf_pins ps7_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net ps7_0_axi_periph_M00_AXI [get_bd_intf_pins peak_top_2_0/s_axi] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net selectio_wiz_2_diff_clk_to_pins [get_bd_intf_ports pm0_clk] [get_bd_intf_pins selectio_pm0/diff_clk_to_pins]
  connect_bd_intf_net -intf_net selectio_wiz_3_diff_clk_to_pins [get_bd_intf_ports pm1_clk] [get_bd_intf_pins selectio_pm1/diff_clk_to_pins]
  connect_bd_intf_net -intf_net selectio_wiz_4_diff_clk_to_pins [get_bd_intf_ports pm2_clk] [get_bd_intf_pins selectio_pm2/diff_clk_to_pins]
  connect_bd_intf_net -intf_net window_top_2_0_M_AXIS [get_bd_intf_pins input_top_2_0/S_AXIS] [get_bd_intf_pins window_top_2_0/M_AXIS]
  connect_bd_intf_net -intf_net xmux_M00_AXI [get_bd_intf_pins regs_0/S_AXI] [get_bd_intf_pins xmux/M00_AXI]
  connect_bd_intf_net -intf_net xmux_M03_AXI [get_bd_intf_pins galvo_top_0/s_axi_h] [get_bd_intf_pins xmux/M03_AXI]
  connect_bd_intf_net -intf_net xmux_M04_AXI [get_bd_intf_pins galvo_top_0/s_axi_v] [get_bd_intf_pins xmux/M04_AXI]
  connect_bd_intf_net -intf_net xmux_M05_AXI [get_bd_intf_pins window_top_2_0/s_axi_coef] [get_bd_intf_pins xmux/M05_AXI]
  connect_bd_intf_net -intf_net xmux_M06_AXI [get_bd_intf_pins pm_top_0/s_axi_pma] [get_bd_intf_pins xmux/M06_AXI]
  connect_bd_intf_net -intf_net xmux_M07_AXI [get_bd_intf_pins pm_top_0/s_axi_pmb] [get_bd_intf_pins xmux/M07_AXI]
  connect_bd_intf_net -intf_net xmux_M08_AXI [get_bd_intf_pins pm_top_1/s_axi_pma] [get_bd_intf_pins xmux/M08_AXI]
  connect_bd_intf_net -intf_net xmux_M09_AXI [get_bd_intf_pins pm_top_1/s_axi_pmb] [get_bd_intf_pins xmux/M09_AXI]
  connect_bd_intf_net -intf_net xmux_M10_AXI [get_bd_intf_pins pm_top_2/s_axi_pma] [get_bd_intf_pins xmux/M10_AXI]
  connect_bd_intf_net -intf_net xmux_M11_AXI [get_bd_intf_pins pm_top_2/s_axi_pmb] [get_bd_intf_pins xmux/M11_AXI]
  connect_bd_intf_net -intf_net xmux_M12_AXI [get_bd_intf_pins axi_mm2s_mapper_0/S_AXI] [get_bd_intf_pins xmux/M12_AXI]
  connect_bd_intf_net -intf_net xmux_M13_AXI [get_bd_intf_pins input_top_2_0/s_axi_adc0] [get_bd_intf_pins xmux/M13_AXI]
  connect_bd_intf_net -intf_net xmux_M14_AXI [get_bd_intf_pins fft_top_2_0/s_axi_fft] [get_bd_intf_pins xmux/M14_AXI]

  # Create port connections
  connect_bd_net -net Net1 [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins fft_top_2_0/m_axis_data1_aclk] [get_bd_pins fft_top_2_0/s_axis_data1_aclk] [get_bd_pins input_top_2_0/m_axis_data1_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data1_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data1_aclk] [get_bd_pins peak_top_2_0/s_axis_data1_aclk]
  connect_bd_net -net Net2 [get_bd_pins clk_wiz_1/clk_out2] [get_bd_pins fft_top_2_0/m_axis_data2_aclk] [get_bd_pins fft_top_2_0/s_axis_data2_aclk] [get_bd_pins input_top_2_0/m_axis_data2_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data2_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data2_aclk] [get_bd_pins peak_top_2_0/s_axis_data2_aclk]
  connect_bd_net -net Net3 [get_bd_pins clk_wiz_1/clk_out3] [get_bd_pins fft_top_2_0/m_axis_data3_aclk] [get_bd_pins fft_top_2_0/s_axis_data3_aclk] [get_bd_pins input_top_2_0/m_axis_data3_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data3_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data3_aclk] [get_bd_pins peak_top_2_0/s_axis_data3_aclk]
  connect_bd_net -net Net4 [get_bd_pins clk_wiz_1/clk_out4] [get_bd_pins fft_top_2_0/m_axis_data4_aclk] [get_bd_pins fft_top_2_0/s_axis_data4_aclk] [get_bd_pins input_top_2_0/m_axis_data4_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data4_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data4_aclk] [get_bd_pins peak_top_2_0/s_axis_data4_aclk]
  connect_bd_net -net Net5 [get_bd_pins clk_wiz_1/clk_out5] [get_bd_pins fft_top_2_0/m_axis_data5_aclk] [get_bd_pins fft_top_2_0/s_axis_data5_aclk] [get_bd_pins input_top_2_0/m_axis_data5_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data5_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data5_aclk] [get_bd_pins peak_top_2_0/s_axis_data5_aclk]
  connect_bd_net -net Net6 [get_bd_pins clk_wiz_1/clk_out6] [get_bd_pins fft_top_2_0/m_axis_data6_aclk] [get_bd_pins fft_top_2_0/s_axis_data6_aclk] [get_bd_pins input_top_2_0/m_axis_data6_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data6_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data6_aclk] [get_bd_pins peak_top_2_0/s_axis_data6_aclk]
  connect_bd_net -net Net7 [get_bd_pins clk_wiz_1/clk_out7] [get_bd_pins fft_top_2_0/m_axis_data7_aclk] [get_bd_pins fft_top_2_0/s_axis_data7_aclk] [get_bd_pins input_top_2_0/m_axis_data7_aclk] [get_bd_pins mult_add_top_2_0/m_axis_data7_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data7_aclk] [get_bd_pins peak_top_2_0/s_axis_data7_aclk]
  connect_bd_net -net adc_miso_0_1 [get_bd_ports adc_miso] [get_bd_pins spi_adc_pm_0/adc_miso]
  connect_bd_net -net all_rstn_sync_0_lresetn_stream [get_bd_pins all_rstn_sync_0/lresetn_stream] [get_bd_pins input_top_2_0/lreset_n] [get_bd_pins mc_top_0/lresetn_stream] [get_bd_pins peak_top_2_0/lresetn_stream]
  connect_bd_net -net all_rstn_sync_0_rst_adc_n [get_bd_pins all_rstn_sync_0/rst_adc_n] [get_bd_pins galvo_top_0/rst_adc_n] [get_bd_pins input_top_2_0/M_AXIS_ARESETN] [get_bd_pins input_top_2_0/S_AXIS_ARESETN] [get_bd_pins input_top_2_0/rst_adc_n] [get_bd_pins mc_top_0/rst_adc_n] [get_bd_pins pm_top_0/rst_adc_n] [get_bd_pins pm_top_1/rst_adc_n] [get_bd_pins pm_top_2/rst_adc_n] [get_bd_pins window_top_2_0/M_AXIS_ARESETN] [get_bd_pins window_top_2_0/S_AXIS_ARESETN]
  connect_bd_net -net all_rstn_sync_0_rst_clk10 [get_bd_pins all_rstn_sync_0/rst_clk10] [get_bd_pins mc_top_0/rst_clk10]
  connect_bd_net -net all_rstn_sync_0_rst_control_n [get_bd_pins all_rstn_sync_0/rst_control_n] [get_bd_pins fft_top_2_0/rst_control_n] [get_bd_pins galvo_top_0/rst_control_n] [get_bd_pins input_top_2_0/rst_control_n] [get_bd_pins mc_top_0/rst_control_n] [get_bd_pins pm_top_0/rst_control_n] [get_bd_pins pm_top_1/rst_control_n] [get_bd_pins pm_top_2/rst_control_n]
  connect_bd_net -net all_rstn_sync_0_rst_stream_n [get_bd_pins all_rstn_sync_0/rst_stream_n] [get_bd_pins input_top_2_0/rst_stream_n] [get_bd_pins mc_top_0/rst_stream_n]
  connect_bd_net -net clk_wiz_0_clk_out1 [get_bd_pins clk_wiz_0/clk_out1] [get_bd_pins pm_resets_0/dest_clk] [get_bd_pins pm_top_0/fast_c] [get_bd_pins selectio_pm0/clk_in]
  connect_bd_net -net clk_wiz_0_clk_out2 [get_bd_pins clk_wiz_0/clk_out2] [get_bd_pins pm_resets_1/dest_clk] [get_bd_pins pm_top_1/fast_c] [get_bd_pins selectio_pm1/clk_in]
  connect_bd_net -net clk_wiz_0_clk_out3 [get_bd_pins clk_wiz_0/clk_out3] [get_bd_pins pm_resets_2/dest_clk] [get_bd_pins pm_top_2/fast_c] [get_bd_pins selectio_pm2/clk_in]
  connect_bd_net -net data_in_from_pins_n_0_1 [get_bd_ports adc_n] [get_bd_pins adc_input/data_in_from_pins_n]
  connect_bd_net -net data_in_from_pins_p_0_1 [get_bd_ports adc_p] [get_bd_pins adc_input/data_in_from_pins_p]
  connect_bd_net -net fft_top_2_0_dbg_fft_capture_wren [get_bd_pins fft_top_2_0/dbg_fft_capture_wren] [get_bd_pins xlconcat_0/In6]
  connect_bd_net -net fft_top_2_0_dbg_in_capture [get_bd_pins fft_top_2_0/dbg_in_capture] [get_bd_pins xlconcat_0/In7]
  connect_bd_net -net fft_top_2_0_fft_events [get_bd_pins fft_top_2_0/fft_events] [get_bd_pins mc_top_0/fft_events]
  connect_bd_net -net fft_top_2_0_xk [get_bd_pins fft_top_2_0/xk] [get_bd_pins mult_add_top_2_0/xk_in]
  connect_bd_net -net galvo_top_0_csn [get_bd_ports galvo_csn] [get_bd_pins galvo_top_0/csn]
  connect_bd_net -net galvo_top_0_galvo_spi_done [get_bd_pins galvo_top_0/galvo_spi_done] [get_bd_pins mc_top_0/galvo_spi_done]
  connect_bd_net -net galvo_top_0_galvoh [get_bd_pins galvo_top_0/galvoh] [get_bd_pins mc_top_0/galvoh]
  connect_bd_net -net galvo_top_0_galvov [get_bd_pins galvo_top_0/galvov] [get_bd_pins mc_top_0/galvov]
  connect_bd_net -net galvo_top_0_mosi_o [get_bd_ports galvo_mosi] [get_bd_pins galvo_top_0/mosi_o]
  connect_bd_net -net galvo_top_0_sclk [get_bd_ports galvo_sclk] [get_bd_pins galvo_top_0/sclk]
  connect_bd_net -net gpio_0_rstn_adc [get_bd_ports rstn_adc] [get_bd_pins mc_top_0/rstn_adc]
  connect_bd_net -net gpio_0_rstn_pm [get_bd_ports rstn_pm] [get_bd_pins mc_top_0/rstn_pm]
  connect_bd_net -net input_top_0_bitslips [get_bd_pins adc_input/bitslip] [get_bd_pins input_top_2_0/bitslips] [get_bd_pins mc_top_0/bitslips] [get_bd_pins xlslice_0/Din]
  connect_bd_net -net input_top_2_0_dbg_mux_o [get_bd_pins input_top_2_0/dbg_mux_o] [get_bd_pins xlslice_1/Din] [get_bd_pins xlslice_2/Din] [get_bd_pins xlslice_3/Din]
  connect_bd_net -net input_top_2_0_dbg_wr_en [get_bd_pins input_top_2_0/dbg_wr_en] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net input_top_2_0_debug_data [get_bd_pins input_top_2_0/debug_data] [get_bd_pins xlslice_4/Din]
  connect_bd_net -net mc_top_0_dbg_mux [get_bd_pins input_top_2_0/dbg_mux] [get_bd_pins mc_top_0/dbg_mux]
  connect_bd_net -net mc_top_0_debug_go [get_bd_pins input_top_2_0/debug_go] [get_bd_pins mc_top_0/input_debug_go]
  connect_bd_net -net mc_top_0_debug_status [get_bd_pins mc_top_0/debug_status] [get_bd_pins regs_0/in_reg16]
  connect_bd_net -net mc_top_0_fft_capture [get_bd_pins fft_top_2_0/fft_capture] [get_bd_pins mc_top_0/fft_capture]
  connect_bd_net -net mc_top_0_fft_rst [get_bd_pins fft_top_2_0/reset] [get_bd_pins mc_top_0/fft_rst]
  connect_bd_net -net mc_top_0_fifo_rst [get_bd_pins input_top_2_0/reset_fifo] [get_bd_pins mc_top_0/fifo_rst]
  connect_bd_net -net mc_top_0_force_nowindow [get_bd_pins mc_top_0/force_nowindow] [get_bd_pins window_top_2_0/force_nowindow]
  connect_bd_net -net mc_top_0_galvo_go [get_bd_pins galvo_top_0/pixel_done] [get_bd_pins mc_top_0/galvo_go] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net mc_top_0_last [get_bd_pins input_top_2_0/last] [get_bd_pins mc_top_0/last]
  connect_bd_net -net mc_top_0_sampling [get_bd_pins input_top_2_0/sampling] [get_bd_pins mc_top_0/sampling]
  connect_bd_net -net mc_top_0_sel_clk_rst [get_bd_pins adc_input/clk_reset] [get_bd_pins all_rstn_sync_0/sel_clk_rst] [get_bd_pins pm_resets_0/clk_rst_in] [get_bd_pins pm_resets_1/clk_rst_in] [get_bd_pins pm_resets_2/clk_rst_in]
  connect_bd_net -net mc_top_0_sel_io_rst [get_bd_pins adc_input/io_reset] [get_bd_pins all_rstn_sync_0/sel_io_rst] [get_bd_pins pm_resets_0/io_rst_in] [get_bd_pins pm_resets_1/io_rst_in] [get_bd_pins pm_resets_2/io_rst_in]
  connect_bd_net -net mc_top_0_select_average [get_bd_pins mc_top_0/select_average] [get_bd_pins mult_add_top_2_0/select_average]
  connect_bd_net -net mc_top_0_status [get_bd_pins mc_top_0/status] [get_bd_pins regs_0/in_reg0]
  connect_bd_net -net mc_top_0_sync_awg [get_bd_pins mc_top_0/sync_awg] [get_bd_pins pm_top_0/sync_awg] [get_bd_pins pm_top_1/sync_awg] [get_bd_pins pm_top_2/sync_awg]
  connect_bd_net -net mult_add_top_2_0_xk_out [get_bd_pins mult_add_top_2_0/xk_out] [get_bd_pins peak_top_2_0/xk]
  connect_bd_net -net peak_top_2_0_peaks_ready [get_bd_pins mc_top_0/peaks_ready] [get_bd_pins peak_top_2_0/peaks_ready]
  connect_bd_net -net pm0_miso_0_1 [get_bd_ports pm0_miso] [get_bd_pins spi_adc_pm_0/pm0_miso]
  connect_bd_net -net pm1_miso_0_1 [get_bd_ports pm1_miso] [get_bd_pins spi_adc_pm_0/pm1_miso]
  connect_bd_net -net pm2_miso_0_1 [get_bd_ports pm2_miso] [get_bd_pins spi_adc_pm_0/pm2_miso]
  connect_bd_net -net pm_resets_0_clk_rst_out [get_bd_pins pm_resets_0/clk_rst_out] [get_bd_pins selectio_pm0/clk_reset]
  connect_bd_net -net pm_resets_0_io_rst_out [get_bd_pins pm_resets_0/io_rst_out] [get_bd_pins selectio_pm0/io_reset]
  connect_bd_net -net pm_resets_1_clk_rst_out [get_bd_pins pm_resets_1/clk_rst_out] [get_bd_pins selectio_pm1/clk_reset]
  connect_bd_net -net pm_resets_1_io_rst_out [get_bd_pins pm_resets_1/io_rst_out] [get_bd_pins selectio_pm1/io_reset]
  connect_bd_net -net pm_resets_2_clk_rst_out [get_bd_pins pm_resets_2/clk_rst_out] [get_bd_pins selectio_pm2/clk_reset]
  connect_bd_net -net pm_resets_2_io_rst_out [get_bd_pins pm_resets_2/io_rst_out] [get_bd_pins selectio_pm2/io_reset]
  connect_bd_net -net pm_top_0_data_out_from_device [get_bd_pins pm_top_0/data_out_from_device] [get_bd_pins selectio_pm0/data_out_from_device]
  connect_bd_net -net pm_top_0_status [get_bd_pins pm_top_0/status] [get_bd_pins regs_0/in_reg1]
  connect_bd_net -net pm_top_1_data_out_from_device [get_bd_pins pm_top_1/data_out_from_device] [get_bd_pins selectio_pm1/data_out_from_device]
  connect_bd_net -net pm_top_1_status [get_bd_pins pm_top_1/status] [get_bd_pins regs_0/in_reg2]
  connect_bd_net -net pm_top_2_data_out_from_device [get_bd_pins pm_top_2/data_out_from_device] [get_bd_pins selectio_pm2/data_out_from_device]
  connect_bd_net -net pm_top_2_status [get_bd_pins pm_top_2/status] [get_bd_pins regs_0/in_reg3]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins all_rstn_sync_0/clk_stream] [get_bd_pins clk_wiz_1/clk_in1] [get_bd_pins fft_top_2_0/m_axis_data0_aclk] [get_bd_pins fft_top_2_0/s_axis_data0_aclk] [get_bd_pins input_top_2_0/clk_stream] [get_bd_pins input_top_2_0/m_axis_data0_aclk] [get_bd_pins mc_top_0/clk_stream] [get_bd_pins mult_add_top_2_0/m_axis_data0_aclk] [get_bd_pins mult_add_top_2_0/s_axis_data0_aclk] [get_bd_pins peak_top_2_0/s_axis_data0_aclk] [get_bd_pins pm_resets_0/src_clk] [get_bd_pins pm_resets_1/src_clk] [get_bd_pins pm_resets_2/src_clk] [get_bd_pins processing_system7_0/FCLK_CLK0]
  connect_bd_net -net processing_system7_0_FCLK_CLK1 [get_bd_pins all_rstn_sync_0/clk_control] [get_bd_pins axi_mm2s_mapper_0/aclk] [get_bd_pins clk_wiz_0/clk_in1] [get_bd_pins fft_top_2_0/clk_control] [get_bd_pins fft_top_2_0/m_axis_status_aclk] [get_bd_pins fft_top_2_0/s_axi_fft_aclk] [get_bd_pins galvo_top_0/s_axi_h_aclk] [get_bd_pins galvo_top_0/s_axi_v_aclk] [get_bd_pins input_top_2_0/clk_control] [get_bd_pins input_top_2_0/s_axi_adc0_aclk] [get_bd_pins mc_top_0/clk_control] [get_bd_pins memaxi_reset/slowest_sync_clk] [get_bd_pins pm_top_0/clk_control] [get_bd_pins pm_top_0/s_axi_pma_aclk] [get_bd_pins pm_top_0/s_axi_pmb_aclk] [get_bd_pins pm_top_1/clk_control] [get_bd_pins pm_top_1/s_axi_pma_aclk] [get_bd_pins pm_top_1/s_axi_pmb_aclk] [get_bd_pins pm_top_2/clk_control] [get_bd_pins pm_top_2/s_axi_pma_aclk] [get_bd_pins pm_top_2/s_axi_pmb_aclk] [get_bd_pins processing_system7_0/FCLK_CLK1] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins regs_0/S_AXI_ACLK] [get_bd_pins spi_adc_pm_0/clk] [get_bd_pins window_top_2_0/s_axi_coef_aclk] [get_bd_pins xmux/ACLK] [get_bd_pins xmux/M00_ACLK] [get_bd_pins xmux/M01_ACLK] [get_bd_pins xmux/M02_ACLK] [get_bd_pins xmux/M03_ACLK] [get_bd_pins xmux/M04_ACLK] [get_bd_pins xmux/M05_ACLK] [get_bd_pins xmux/M06_ACLK] [get_bd_pins xmux/M07_ACLK] [get_bd_pins xmux/M08_ACLK] [get_bd_pins xmux/M09_ACLK] [get_bd_pins xmux/M10_ACLK] [get_bd_pins xmux/M11_ACLK] [get_bd_pins xmux/M12_ACLK] [get_bd_pins xmux/M13_ACLK] [get_bd_pins xmux/M14_ACLK] [get_bd_pins xmux/S00_ACLK]
  connect_bd_net -net processing_system7_0_FCLK_CLK2 [get_bd_pins all_rstn_sync_0/clk10] [get_bd_pins mc_top_0/clk10] [get_bd_pins processing_system7_0/FCLK_CLK2] [get_bd_pins vga_0/clk_1M]
  connect_bd_net -net processing_system7_0_FCLK_CLK3 [get_bd_pins peak_top_2_0/s_axi_aclk] [get_bd_pins processing_system7_0/FCLK_CLK3] [get_bd_pins processing_system7_0/M_AXI_GP1_ACLK] [get_bd_pins ps7_0_axi_periph/ACLK] [get_bd_pins ps7_0_axi_periph/M00_ACLK] [get_bd_pins ps7_0_axi_periph/S00_ACLK] [get_bd_pins rst_ps7_0_200M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins memaxi_reset/ext_reset_in] [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_200M/ext_reset_in]
  connect_bd_net -net regs_0_out_reg0 [get_bd_pins mc_top_0/control] [get_bd_pins regs_0/out_reg0]
  connect_bd_net -net regs_0_out_reg1 [get_bd_pins pm_top_0/control_in] [get_bd_pins regs_0/out_reg1]
  connect_bd_net -net regs_0_out_reg2 [get_bd_pins pm_top_1/control_in] [get_bd_pins regs_0/out_reg2]
  connect_bd_net -net regs_0_out_reg3 [get_bd_pins pm_top_2/control_in] [get_bd_pins regs_0/out_reg3]
  connect_bd_net -net regs_0_out_reg4 [get_bd_pins galvo_top_0/control] [get_bd_pins regs_0/out_reg4]
  connect_bd_net -net regs_0_out_reg5 [get_bd_pins galvo_top_0/manual] [get_bd_pins regs_0/out_reg5]
  connect_bd_net -net regs_0_out_reg6 [get_bd_pins regs_0/out_reg6] [get_bd_pins spi_adc_pm_0/control_adc]
  connect_bd_net -net regs_0_out_reg7 [get_bd_pins regs_0/out_reg7] [get_bd_pins spi_adc_pm_0/data_adc]
  connect_bd_net -net regs_0_out_reg8 [get_bd_pins regs_0/out_reg8] [get_bd_pins spi_adc_pm_0/control_pm0]
  connect_bd_net -net regs_0_out_reg9 [get_bd_pins regs_0/out_reg9] [get_bd_pins spi_adc_pm_0/data_pm0]
  connect_bd_net -net regs_0_out_reg10 [get_bd_pins regs_0/out_reg10] [get_bd_pins spi_adc_pm_0/control_pm1]
  connect_bd_net -net regs_0_out_reg11 [get_bd_pins regs_0/out_reg11] [get_bd_pins spi_adc_pm_0/data_pm1]
  connect_bd_net -net regs_0_out_reg12 [get_bd_pins regs_0/out_reg12] [get_bd_pins spi_adc_pm_0/control_pm2]
  connect_bd_net -net regs_0_out_reg13 [get_bd_pins regs_0/out_reg13] [get_bd_pins spi_adc_pm_0/data_pm2]
  connect_bd_net -net regs_0_out_reg14 [get_bd_pins regs_0/out_reg14] [get_bd_pins vga_0/vga_in]
  connect_bd_net -net regs_0_out_reg15 [get_bd_pins regs_0/in_reg15] [get_bd_pins regs_0/out_reg15]
  connect_bd_net -net regs_0_out_reg16 [get_bd_pins mc_top_0/debug] [get_bd_pins regs_0/out_reg16]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins all_rstn_sync_0/asyncrst_n] [get_bd_pins axi_mm2s_mapper_0/aresetn] [get_bd_pins fft_top_2_0/s_axi_fft_aresetn] [get_bd_pins galvo_top_0/s_axi_h_aresetn] [get_bd_pins galvo_top_0/s_axi_v_aresetn] [get_bd_pins input_top_2_0/s_axi_adc0_aresetn] [get_bd_pins memaxi_reset/peripheral_aresetn] [get_bd_pins pm_top_0/s_axi_pma_aresetn] [get_bd_pins pm_top_0/s_axi_pmb_aresetn] [get_bd_pins pm_top_1/s_axi_pma_aresetn] [get_bd_pins pm_top_1/s_axi_pmb_aresetn] [get_bd_pins pm_top_2/s_axi_pma_aresetn] [get_bd_pins pm_top_2/s_axi_pmb_aresetn] [get_bd_pins regs_0/S_AXI_ARESETN] [get_bd_pins window_top_2_0/s_axi_coef_aresetn] [get_bd_pins xmux/ARESETN] [get_bd_pins xmux/M00_ARESETN] [get_bd_pins xmux/M01_ARESETN] [get_bd_pins xmux/M02_ARESETN] [get_bd_pins xmux/M03_ARESETN] [get_bd_pins xmux/M04_ARESETN] [get_bd_pins xmux/M05_ARESETN] [get_bd_pins xmux/M06_ARESETN] [get_bd_pins xmux/M07_ARESETN] [get_bd_pins xmux/M08_ARESETN] [get_bd_pins xmux/M09_ARESETN] [get_bd_pins xmux/M10_ARESETN] [get_bd_pins xmux/M11_ARESETN] [get_bd_pins xmux/M12_ARESETN] [get_bd_pins xmux/M13_ARESETN] [get_bd_pins xmux/M14_ARESETN] [get_bd_pins xmux/S00_ARESETN]
  connect_bd_net -net rst_ps7_0_100M_peripheral_reset [get_bd_pins clk_wiz_0/reset] [get_bd_pins clk_wiz_1/reset] [get_bd_pins memaxi_reset/peripheral_reset] [get_bd_pins spi_adc_pm_0/reset]
  connect_bd_net -net rst_ps7_0_200M_peripheral_aresetn [get_bd_pins peak_top_2_0/s_axi_aresetn] [get_bd_pins ps7_0_axi_periph/ARESETN] [get_bd_pins ps7_0_axi_periph/M00_ARESETN] [get_bd_pins ps7_0_axi_periph/S00_ARESETN] [get_bd_pins rst_ps7_0_200M/peripheral_aresetn]
  connect_bd_net -net selectio_wiz_0_clk_div_out [get_bd_pins adc_input/clk_div_out] [get_bd_pins all_rstn_sync_0/clk_adc] [get_bd_pins galvo_top_0/clk_adc] [get_bd_pins input_top_2_0/M_AXIS_ACLK] [get_bd_pins input_top_2_0/S_AXIS_ACLK] [get_bd_pins input_top_2_0/clk_adc] [get_bd_pins mc_top_0/clk_adc] [get_bd_pins pm_top_0/clk_adc] [get_bd_pins pm_top_1/clk_adc] [get_bd_pins pm_top_2/clk_adc] [get_bd_pins window_top_2_0/M_AXIS_ACLK] [get_bd_pins window_top_2_0/S_AXIS_ACLK]
  connect_bd_net -net selectio_wiz_0_data_in_to_device [get_bd_pins adc_input/data_in_to_device] [get_bd_pins input_top_2_0/data_in_to_device]
  connect_bd_net -net selectio_wiz_2_data_out_to_pins_n [get_bd_ports pm0_out_n] [get_bd_pins selectio_pm0/data_out_to_pins_n]
  connect_bd_net -net selectio_wiz_2_data_out_to_pins_p [get_bd_ports pm0_out_p] [get_bd_pins selectio_pm0/data_out_to_pins_p]
  connect_bd_net -net selectio_wiz_3_data_out_to_pins_n [get_bd_ports pm1_out_n] [get_bd_pins selectio_pm1/data_out_to_pins_n]
  connect_bd_net -net selectio_wiz_3_data_out_to_pins_p [get_bd_ports pm1_out_p] [get_bd_pins selectio_pm1/data_out_to_pins_p]
  connect_bd_net -net selectio_wiz_4_data_out_to_pins_n [get_bd_ports pm2_out_n] [get_bd_pins selectio_pm2/data_out_to_pins_n]
  connect_bd_net -net selectio_wiz_4_data_out_to_pins_p [get_bd_ports pm2_out_p] [get_bd_pins selectio_pm2/data_out_to_pins_p]
  connect_bd_net -net spi_adc_pm_0_csn_adc [get_bd_ports csn_adc] [get_bd_pins spi_adc_pm_0/csn_adc]
  connect_bd_net -net spi_adc_pm_0_csn_pm0 [get_bd_ports csn_pm0] [get_bd_pins spi_adc_pm_0/csn_pm0]
  connect_bd_net -net spi_adc_pm_0_csn_pm1 [get_bd_ports csn_pm1] [get_bd_pins spi_adc_pm_0/csn_pm1]
  connect_bd_net -net spi_adc_pm_0_csn_pm2 [get_bd_ports csn_pm2] [get_bd_pins spi_adc_pm_0/csn_pm2]
  connect_bd_net -net spi_adc_pm_0_dataout_adc [get_bd_pins regs_0/in_reg7] [get_bd_pins spi_adc_pm_0/dataout_adc]
  connect_bd_net -net spi_adc_pm_0_dataout_pm0 [get_bd_pins regs_0/in_reg9] [get_bd_pins spi_adc_pm_0/dataout_pm0]
  connect_bd_net -net spi_adc_pm_0_dataout_pm1 [get_bd_pins regs_0/in_reg11] [get_bd_pins spi_adc_pm_0/dataout_pm1]
  connect_bd_net -net spi_adc_pm_0_dataout_pm2 [get_bd_pins regs_0/in_reg13] [get_bd_pins spi_adc_pm_0/dataout_pm2]
  connect_bd_net -net spi_adc_pm_0_mosi_adc [get_bd_ports mosi_adc] [get_bd_pins spi_adc_pm_0/mosi_adc]
  connect_bd_net -net spi_adc_pm_0_mosi_pm0 [get_bd_ports mosi_pm0] [get_bd_pins spi_adc_pm_0/mosi_pm0]
  connect_bd_net -net spi_adc_pm_0_mosi_pm1 [get_bd_ports mosi_pm1] [get_bd_pins spi_adc_pm_0/mosi_pm1]
  connect_bd_net -net spi_adc_pm_0_mosi_pm2 [get_bd_ports mosi_pm2] [get_bd_pins spi_adc_pm_0/mosi_pm2]
  connect_bd_net -net spi_adc_pm_0_sclk_adc [get_bd_ports sclk_adc] [get_bd_pins spi_adc_pm_0/sclk_adc]
  connect_bd_net -net spi_adc_pm_0_sclk_pm0 [get_bd_ports sclk_pm0] [get_bd_pins spi_adc_pm_0/sclk_pm0]
  connect_bd_net -net spi_adc_pm_0_sclk_pm1 [get_bd_ports sclk_pm1] [get_bd_pins spi_adc_pm_0/sclk_pm1]
  connect_bd_net -net spi_adc_pm_0_sclk_pm2 [get_bd_ports sclk_pm2] [get_bd_pins spi_adc_pm_0/sclk_pm2]
  connect_bd_net -net spi_adc_pm_0_status_adc [get_bd_pins regs_0/in_reg6] [get_bd_pins spi_adc_pm_0/status_adc]
  connect_bd_net -net spi_adc_pm_0_status_pm0 [get_bd_pins regs_0/in_reg8] [get_bd_pins spi_adc_pm_0/status_pm0]
  connect_bd_net -net spi_adc_pm_0_status_pm1 [get_bd_pins regs_0/in_reg10] [get_bd_pins spi_adc_pm_0/status_pm1]
  connect_bd_net -net spi_adc_pm_0_status_pm2 [get_bd_pins regs_0/in_reg12] [get_bd_pins spi_adc_pm_0/status_pm2]
  connect_bd_net -net vga_0_debug [get_bd_ports debug] [get_bd_pins vga_0/debug]
  connect_bd_net -net vga_0_down [get_bd_ports down] [get_bd_pins vga_0/down]
  connect_bd_net -net vga_0_step [get_bd_ports step] [get_bd_pins vga_0/step]
  connect_bd_net -net vga_0_up [get_bd_ports up] [get_bd_pins vga_0/up]
  connect_bd_net -net vga_0_vga_out [get_bd_pins regs_0/in_reg14] [get_bd_pins vga_0/vga_out]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins vga_0/dbgA] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axi_mm2s_mapper_0/s_axis_tvalid] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_3_dout [get_bd_pins regs_0/in_reg4] [get_bd_pins regs_0/in_reg5] [get_bd_pins xlconstant_3/dout]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins xlconcat_0/In1] [get_bd_pins xlslice_0/Dout]
  connect_bd_net -net xlslice_1_Dout [get_bd_pins xlconcat_0/In5] [get_bd_pins xlslice_1/Dout]
  connect_bd_net -net xlslice_2_Dout [get_bd_pins xlconcat_0/In3] [get_bd_pins xlslice_2/Dout]
  connect_bd_net -net xlslice_3_Dout [get_bd_pins xlconcat_0/In4] [get_bd_pins xlslice_3/Dout]
  connect_bd_net -net xlslice_4_Dout [get_bd_pins vga_0/dbgB] [get_bd_pins xlslice_4/Dout]

  # Create address segments
  assign_bd_address -offset 0x43F10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_mm2s_mapper_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x43CC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs fft_top_2_0/s_axi_fft/reg0] -force
  assign_bd_address -offset 0x43C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs galvo_top_0/s_axi_h/reg0] -force
  assign_bd_address -offset 0x43C10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs galvo_top_0/s_axi_v/reg0] -force
  assign_bd_address -offset 0x43CB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs input_top_2_0/s_axi_adc0/reg0] -force
  assign_bd_address -offset 0x83C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs peak_top_2_0/s_axi/reg0] -force
  assign_bd_address -offset 0x43C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_0/s_axi_pmb/reg0] -force
  assign_bd_address -offset 0x43C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_0/s_axi_pma/reg0] -force
  assign_bd_address -offset 0x43C50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_1/s_axi_pmb/reg0] -force
  assign_bd_address -offset 0x43C40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_1/s_axi_pma/reg0] -force
  assign_bd_address -offset 0x43C70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_2/s_axi_pmb/reg0] -force
  assign_bd_address -offset 0x43C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs pm_top_2/s_axi_pma/reg0] -force
  assign_bd_address -offset 0x43D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs regs_0/S_AXI/reg0] -force
  assign_bd_address -offset 0x43C80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs window_top_2_0/s_axi_coef/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


