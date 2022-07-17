import numpy as np

#Glider
glider = np.zeros((5,5))
glider[1,1] = 1;
glider[3,1] = 1;
glider[2,2] = 1;
glider[3,2] = 1;
glider[2,3] = 1;
glider = glider.T;

#Pulsar
p = np.zeros((6,6))
p[2:3,0] = 1;
p[3,0:3] = 1;
p[4,1] = 1;
p[5,2:5] = 1;
p[4,3] = 1;
p=p.T+p
pulsar=np.zeros((15,15))
pulsar[1:7,1:7] = p
pulsar[8:14, 1:7] = np.flipud(p)
pulsar[1:7, 8:14] = np.fliplr(p)
pulsar[8:14, 8:14] = np.flipud(np.fliplr(p))

#Spaceship
spaceship = np.zeros((5,5))
spaceship[1:3,0:2] = 1;
spaceship[0:2,1:3] = 1;
spaceship[3,1:4] = 1;
spaceship[2,3] = 1;
spaceship[4,2] = 1;
spaceship = spaceship.T

#Ring of fire
p = np.zeros((6,6))
p[0:5,5] = 1;
p[5,1:5] = 1;
p[4,0] = 1
p[2,1] = 1
p[3,2:4] = 1
p[1:3,3] = 1
fire=np.zeros((13,13))
fire[1:7,1:7] = p.T
fire[6:12, 1:7] = np.flipud(p.T)
fire[1:7, 6:12] = np.fliplr(p.T)
fire[6:12, 6:12] = np.flipud(np.fliplr(p.T))
  
#Quadpole
p = np.zeros((4,3))
p[0:2,0] = 1;
p[0,1] = 1
p[1,2] = 1
p[3,2] = 1
quad=np.zeros((7,7))
quad[0:3,0:4] = p.T
quad[4:8,3:7] = np.flipud(np.fliplr(p.T))                     

#Example Plate
plate=np.zeros((50,50))
plate[3:3+glider.shape[0], 3:3+glider.shape[1]] = glider
plate[3:3+pulsar.shape[0], 30:30+pulsar.shape[1]] = pulsar
plate[20:20+spaceship.shape[0], 3:3+spaceship.shape[1]] = spaceship
plate[35:35+fire.shape[0], 3:3+fire.shape[1]] = fire
plate[35:35+quad.shape[0], 30:30+quad.shape[1]] = quad
                                                
def conway_out(plate, iterations=100):
    out = f"{plate.shape[0]} {iterations}\n"
    for row in range(plate.shape[0]):
        for col in range(plate.shape[1]):
            out+='%d' % plate[row][col]
        out+="\n"
    out+="\n"
    return out                
                             
out = conway_out(plate)
print(out)      
                             
                             
                             
                             
                             
                             
                             
                             
                             
                             