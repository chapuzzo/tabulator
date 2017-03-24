require 'ap'
require 'tabulator'
require 'benchmark'

t = Tabulator::Reader.new '1PknTXlLmn6yQq2ialL5Ax4XuGPH0oz-YYVDObVkNtjE'
ws = t[0]
ap ws

ap :apellidos_split
ap apellidos_split

apellidos_split = ws.apply(:apellidos){|x| x.split}
ap :ws
ap ws


ap :apellidos_split
ap apellidos_split

# ap apellidos_split.only(:apellidos)
# apellidos_split_reversed = apellidos_split.apply(:apellidos){|x| x.map(&:reverse)}

# ap :ws
# ap ws
# ap :apellidos_split
# ap apellidos_split
# ap :apellidos_split_reversed
# ap apellidos_split_reversed



# ap v = ws.only(:coordenadas).apply(:coordenadas){5}
# ap ws

# ap v.apply(:coordenadas){|x| x.to_s}

# ap ws.apply(:coordenadas){9}
# ap ws
exit
