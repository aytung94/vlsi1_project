#######################################################
#                                                     #
#  Encounter Command Logging File                     #
#  Created on Wed Dec 13 14:22:12 2017                #
#                                                     #
#######################################################

#@(#)CDS: Encounter v09.12-s159_1 (64bit) 07/15/2010 13:17 (Linux 2.6)
#@(#)CDS: NanoRoute v09.12-s013 NR100629-2344/USR64-UB (database version 2.30, 102.1.1) {superthreading v1.15}
#@(#)CDS: CeltIC v09.12-s012_1 (64bit) 07/01/2010 05:52:50 (Linux 2.6.9-78.0.17.ELsmp)
#@(#)CDS: AAE 09.12-e022 (64bit) 07/15/2010 (Linux 2.6.9-89.0.19.ELsmp)
#@(#)CDS: CTE 09.12-s069_1 (64bit) Jul 15 2010 05:35:17 (Linux 2.6.9-89.0.19.ELsmp)
#@(#)CDS: CPE v09.12-s009

dbGet top.name
setUIVar rda_Input ui_gndnet 1'b0
setUIVar rda_Input ui_leffile gscl45nm.lef
setUIVar rda_Input ui_settop 0
setUIVar rda_Input ui_netlist {apr45nm.v TOP.v}
setUIVar rda_Input ui_pwrnet 1'b1
commitConfig
fit
setDrawView fplan
getIoFlowFlag
setFPlanRowSpacingAndType 10.0 1
setIoFlowFlag 0
floorPlan -flip n -site CoreSite -r 1 0.699999 20.0 20 20 20.0
uiSetTool select
getIoFlowFlag
fit
addRing -spacing_bottom 0.3 -width_left 0.5 -width_bottom 0.5 -width_top 0.5 -spacing_top 0.3 -layer_bottom metal1 -center 1 -stacked_via_top_layer metal10 -width_right 0.5 -around core -jog_distance 0.855 -offset_bottom 0.855 -layer_top metal1 -threshold 0.855 -offset_left 0.855 -spacing_right 0.3 -spacing_left 0.3 -offset_right 0.855 -offset_top 0.855 -layer_right metal2 -nets {1'b0 1'b1 } -stacked_via_bottom_layer metal1 -layer_left metal2
getMultiCpuUsage -localCpu
setPlaceMode -fp false
placeDesign -inPlaceOpt -prePlaceOpt
selectWire 10.2200 10.2200 10.7200 947.8800 2 1'b0
setDrawView place
setDrawView ameba
setDrawView fplan
setDrawView place
setNanoRouteMode -quiet -drouteStartIteration default
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail
verifyGeometry
verifyConnectivity -type all -error 1000 -warning 50
extractRC
rcOut -spf gs_div.spf
saveDesign gs_div.enc
