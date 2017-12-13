

"""Az = 64 Bz = 33"""

import copy

Az = 64
Bz = 33

if Az < Bz:
    t = Bz
    Bz = Az
    Az = t
    
Pz = Az + Bz

Aname = "A"
Bname = "B"
Pname = "P"

FAname = "FA"
HAname = "HA"
FAports = ["A", "B", "C", "So", "Co"]
HAports = ["A", "B", "So", "Co"]

moduleName = "MULT_%dx%d" % (Az, Bz)
moduleName = "MULT"
fileName = "mult_%dx%d.v" % (Az, Bz)
fileName = "MULT.v"
extraFileName = "extra_modules"
out_file = open("./%s" % (fileName) , "w")
tab_level = 0

stageLevel = 0
curStage = []
stages = []

wires = []
structures = []

#populate stage with empty arrays
pprod_structure = []
for i in range(0,Az+Bz-1):
    curStage.append([])
    pprod_structure.append([])

#make a list of all partial products
pprod = []
for i in range(0, Az):
    for j in range(0,Bz):
        pprod.append((i,j))

#create 0th stage structure
for pp in pprod:
    pprod_structure[pp[0] + pp[1]].append(pp)
print "partial product list: \n"
print pprod
print ""
print "initilizing product structure:\n"
for ls in pprod_structure:
    print ls
print "\n"

#create 0th stage
for i in range(0,len(pprod_structure)):
    insert_Ls = []
    ls = pprod_structure[i]
    for pp in ls:
        wire_name = "stage%d_r%d_c%d" % (stageLevel, pp[0], pp[1])
        
        insert_Ls.append(wire_name)
        wires.append(wire_name)
        
        sstru = (pp[0], pp[1], wire_name)
        structures.append(sstru)
    curStage[i].extend(insert_Ls)
        
stages.append(curStage)
prevStage = copy.deepcopy(curStage)
curStage = []
stageLevel += 1


while True:
    #find max column height of previous stage
    max_col_length = 0
    for ls in prevStage:
        if len(ls) > max_col_length:
            max_col_length = len(ls)
            
            
    
    #end loop if max_col is 2 or less
    if max_col_length <= 2:
        break
    
    
    
    #process the stage
    #figure out number of columns in next stage
    nxt_stage_length = 0
    most_sig_col_length = len(prevStage[-1])
    if most_sig_col_length > 1:
        nxt_stage_length = len(prevStage) + 1
    else:
        nxt_stage_length = len(prevStage)
        
    #initialize the stage to be inserted
    for i in range(0,nxt_stage_length):
        curStage.append([])
    
    #for each column
    col_num = 0
    for col in prevStage:
        ha = 0
        fa = 0
        
        #group into 3's 2's and 1's
        groups = []
        cnt = 0
        group = 0
        for pp in col:
            if cnt == 0:
                groups.append([])
            groups[group].append(pp)
            cnt += 1
            if cnt >= 3:
                cnt = 0
                group += 1
        print "stage %d :: col %d ::\n" % (stageLevel, col_num)
        
        #for each group
        for grp in groups:
            print grp
            #if its 1 size, just pass to next stage
            if len(grp) == 1:
                curStage[col_num].append(grp[0])
            #if its 2 size, pass through half adder
            elif len(grp) == 2:
                wire_s = "stage%d_c%d_s_ha%d" % (stageLevel, col_num, ha)
                wire_c = "stage%d_c%d_c_ha%d" % (stageLevel, col_num, ha)
                
                wires.append(wire_s)
                wires.append(wire_c)
                
                strct = (grp[0], grp[1], wire_s, wire_c)
                structures.append(strct)
                
                ha += 1
                curStage[col_num].append(wire_s)
                curStage[col_num + 1].append(wire_c)
                
            #if its 3 size, pass through full adder
            elif len(grp) == 3:
                wire_s = "stage%d_c%d_s_fa%d" % (stageLevel, col_num, fa)
                wire_c = "stage%d_c%d_c_fa%d" % (stageLevel, col_num, fa)
                
                wires.append(wire_s)
                wires.append(wire_c)
                
                strct = (grp[0], grp[1], grp[2], wire_s, wire_c)
                structures.append(strct)
                
                fa += 1
                curStage[col_num].append(wire_s)
                curStage[col_num + 1].append(wire_c)
            #error otherwize
            else:
                print "ERRRROOOOORRRRR"
                
        col_num += 1
        print "\n"
    
    #set up next loop
    stages.append(curStage)
    prevStage = copy.deepcopy(curStage)
    curStage = []
    stageLevel += 1

     
for ids, stg in enumerate(stages):
    print "stage%d : \n" % (ids)
    for col in stg:
        print col
    print"\n"

print "all wires:\n"
for wr in wires:
    print wr
print "\nall strcts:\n"
for st in structures:
    print st
print ""
print "begin translating to verilog"

def lines(n):
    for x in range(0, n):
        out_file.write("\n")

print "header"

head = "module %s(%s, %s, %s);\n" % (moduleName, Aname, Bname, Pname)
lines(1)
Astr = "    input [%d:0] %s;\n" % (Az - 1, Aname)
Bstr = "    input [%d:0] %s;\n" % (Bz - 1, Bname)
Pstr = "    output [%d:0] %s;\n" % (Pz - 1, Pname)

out_file.write(head)
lines(1)
out_file.write("    //ports\n")
out_file.write(Astr)
out_file.write(Bstr)
lines(1)
out_file.write(Pstr)
lines(2)

print "all wires"
out_file.write("    //wire names\n")

for wr in wires:
    wire_line = "    wire %s;\n" % (wr)
    out_file.write(wire_line)
out_file.write("\n")
    
#handle finals stage
final_stage = stages[-1]
add1 = []
add2 = []
for col in final_stage:
    if len(col) == 2:
        add1.append(col[0])
        add2.append(col[1])
    else:
        add1.append(col[0])
        add2.append("1'b0")
        
print "add 1 and 2"
print add1
print add2

add1_eq = "{"
for i in reversed(add1):
    print i
    add1_eq += "%s, " % (i)
add1_eq = add1_eq[:-2] + "};"
print "switch"

add2_eq = "{"
for i in reversed(add2):
    print i
    add2_eq += "%s, " % (i)
add2_eq = add2_eq[:-2] + "};"
print add1_eq
print add2_eq

add1_line = "    wire [%d:0] final_add0 = %s\n" % (Pz-1, add1_eq)
add2_line = "    wire [%d:0] final_add1 = %s\n" % (Pz-1, add2_eq)
out_file.write(add1_line)
out_file.write("\n")
out_file.write(add2_line)
out_file.write("\n")
output_str = "    assign %s = final_add0 + final_add1;\n" % (Pname)
out_file.write(output_str)
    
print "all structures"
out_file.write("    //the logic\n")
fa = 0
ha = 0
for st in structures:
    line = ""
    if len(st) == 3:
        line = "    assign %s = %s[%d] & %s[%d];\n" % (st[2], Aname, st[0], Bname, st[1])
    elif len(st) == 4:
        #half adder
        inst_name = "ha_%d" % (ha)
        line = "    %s %s(.%s(%s), .%s(%s), .%s(%s), .%s(%s));\n" % (HAname, inst_name, HAports[0], st[0], HAports[1], st[1], HAports[2], st[2], HAports[3], st[3])
        ha += 1
    elif len(st) == 5:
        #full adder
        inst_name = "fa_%d" % (fa)
        line = "    %s %s(.%s(%s), .%s(%s), .%s(%s), .%s(%s), .%s(%s));\n" % (FAname, inst_name, FAports[0], st[0], FAports[1], st[1], FAports[2], st[2], FAports[3], st[3], FAports[4], st[4])
        fa += 1
    else:
        print "ERRROR"
    
    out_file.write(line)

out_file.write("endmodule")



print "adding extra modules"
out_file.write("\n\n")
extra_file = open("./%s" % (extraFileName), "r")
for line in extra_file.readlines():
    out_file.write(line)













