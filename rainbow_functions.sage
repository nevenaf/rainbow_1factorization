import random

def random_perm(perm,n):  
    for i in range(n):
        j = int(random.uniform(0,i+1))
        perm[i] = perm[j]
        perm[j] = i
        
    return perm
    

# n := total number of vertices in the graph (an even number)
def is_factorization(n,factorization):
    
    ### is every factor a factor?
    good = True
    for factor in factorization:
        seen = [0 for e in range(n)]
        for f in factor:
            seen[f[0]]=1
            seen[f[1]]=1
        total_seen = 0
        for i in range(n):
            total_seen += seen[i]
        good = total_seen == n
        if good == False:
            break
            
    ### is it a factorization        
    if good == True:
        seen = [[0 for e2 in range(n)] for e1 in range(n)]
        for factor in factorization:
            for f in factor:
                seen[f[0]][f[1]] = 1
                seen[f[1]][f[0]] = 1
        for e1 in range(n):
            for e2 in range(e1+1, n):
                if e1!=e2 and seen[e1][e2]==0:
                    return False
    return good

    

# V := underlying Set of elements
# F := 1-factorization
# targets := list of size |V|/2 from set {0,1,...,|V|-1}   
def is_rainy_all_solutions(V, F, targets, pairs, rainbow_factors):
    if targets == []:
        rainbow_factors.append([p for p in pairs])
        return
    else:
        t=targets.pop()
        for e in F[t]:
            if e[0] in V and e[1] in V:
                V.remove(e[0])
                V.remove(e[1])
                pairs.append(e)
                is_rainy_all_solutions(V,F, [tt for tt in targets],pairs,rainbow_factors) 
                V.append(e[0])
                V.append(e[1])
                pairs.pop()
                
    return         

def is_rainy_one_solution(V, F, targets, pairs, rainbow_factors):

    if targets == []:
        rainbow_factors.append([p for p in pairs])
        return
    else:
        t=targets.pop()
        for e in F[t]:
            if (e[0] in V) and (e[1] in V) and (len(rainbow_factors)==0):
                V.remove(e[0])
                V.remove(e[1])
                pairs.append(e)
                is_rainy_one_solution(V,F, [tt for tt in targets],pairs,rainbow_factors) 
                V.append(e[0])
                V.append(e[1])
                pairs.pop()
                
    return 


def num_of_rainy_and_dry(factorization):
    n = len(factorization[0])
    v = 2*n-1
    
    num_rainy = 0
    num_dry = 0
    
    for target in Combinations(range(v), n):
               
        pairs = []
        rainbow_factors = []
        
        is_rainy_one_solution(range(v+1), factorization, target, pairs, rainbow_factors)
        if len(rainbow_factors)>0:
            num_rainy += 1
        else:
            num_dry += 1
            
    return [num_rainy, num_dry]


#####################################################################################
############# 1-rotational 1-factorizations from hooked cyclic Skolem sequence ######
#####################################################################################
def factorization_from_skolem(skolem):
    v = len(skolem)
    n = (v+1)/2
    
    indices=[[] for i in range(n)]
    for i in range(v):
        sym = skolem[i]
        indices[sym].append(i)
    
    F = [[[i,v,i]]+[[int(Zv(i+indices[j][0])),int(Zv(i+indices[j][1])),i] for j in range(1,n)] for i in range(v)]
    return F

        
#####################################################################################
########################### GK_2n factorization  ####################################
#####################################################################################

def GK_2n(n):
    Z = Integers(2*n-1)
    F1 = [[Z(i),Z(-i)] for i in range(1,n)]
    F = [[[2*n-1, int(i)]]+[[int(edge[0]+i), int(edge[1]+i)] for edge in F1] for i in Z ]
#    print 'GK_2n factorization:'    
#    for factor in F:
#        print factor
    return F

def GK2n_to_LS(n):
    v = 2*n-1
    Z = Integers(v)
    
    ls = [[0 for _ in range(v)] for __ in range(v)]
    
    mult_by2 = [Z(2)*Z(a) for a in range(v)]
    for a in range(v):
        for b in range(v):
            if a==b:
                ls[a][b] = a
            else:
                ls[a][b] = mult_by2.index(Z(a)+Z(b))
    return ls  

#####################################################################################
########################### Switching on corners ####################################
#####################################################################################

### off diagonal rainbow-1-factor
def normalized_factorization(n):
    F = []
    v = 2*n-1
    
    if n%2==1:
        F = [[2*i-1,2*i,(4*i-1)%v] for i in range(1,n)]
    else:
        F = [[1,3,4%v], [2,2*n-2,1]]+[[2*i,2*i+1,(4*i+1)%v] for i in range(2,n-1)]
    return F


### list of targets of length n-1 with sum up to 0 in Z_2n-1
def maybe_rainy(n):
    v=2*n-1
    targets = []
    
    for comb in Combinations(range(1,v),n-1):
        sum = 0
        for a in comb:
            sum += a
        if sum%v ==0:
            targets.append(comb)
    return targets



### switch corner elements
### forbidden moves: 
###     1. nothing is connected to zero (nothing sums up to 0)
###     2. no diagonal elements
###     3. no repeats (rainbow has all distinct elts)    
def switch(n, G, rainbow, used_colours, achieved, seen_rainbows):
    
    stuck = True
    for comb in Combinations(n-1, 2):
        ## new colours
        x1,y1,c1 = rainbow[comb[0]]
        x2,y2,c2 = rainbow[comb[1]]
        
        new_options = [[[x1,y1],[x2,y2]],[[x1,y1],[y2,x2]],[[y1,x1],[x2,y2]],[[y1,x1],[y2,x2]]]
        for opt in new_options:
            a1,b1 = opt[0]
            a2,b2 = opt[1]
            d1 = G[a1][b2]
            d2 = G[a2][b1]
           
            if (a1!=b2) and (a2!=b1) and (d1!=0) and (d2!=0) and (d1!=d2) and (((d1 not in used_colours) and (d2 not in used_colours)) or ((d1 in [c1,c2]) and (d2 in [c1,c2]) )):
                stuck = False
                
                used_colours.remove(c1)
                used_colours.remove(c2)
                used_colours.append(d1)
                used_colours.append(d2)
                
                new_rainbow = []
                for i in range(n-1):
                    if i not in comb:
                        new_rainbow.append(rainbow[i])
                new_rainbow = new_rainbow+[[a1,b2,d1], [a2,b1,d2]]
                new_rainbow_colours = [new_rainbow[i][2] for i in range(n-1)]
                
                sorted_colours = sorted(range(n-1), key = lambda i: new_rainbow_colours[i])
                sorted_rainbow = [0 for _ in range(2*n-2)]

                for i in range(n-1):
                    idx = sorted_colours[i]
                    if new_rainbow[idx][0]<new_rainbow[idx][1]:
                        sorted_rainbow[2*i]=new_rainbow[idx][0]
                        sorted_rainbow[2*i+1]=new_rainbow[idx][1]
                    else:
                        sorted_rainbow[2*i]=new_rainbow[idx][1]
                        sorted_rainbow[2*i+1]=new_rainbow[idx][0]
                sorted_rainbow = tuple(sorted_rainbow)
                
                ssorted_colours = [0 for i in range(n-1)]
                for i in range(n-1):
                    ssorted_colours[i] = new_rainbow_colours[sorted_colours[i]]
                ssorted_colours = tuple(ssorted_colours)

                if ssorted_colours not in seen_rainbows:
                    seen_rainbows.append(ssorted_colours)
                              
                if sorted_rainbow not in achieved:
                    achieved.append(sorted_rainbow)
                    switch(n,G,new_rainbow,used_colours,achieved, seen_rainbows)
                    
                
                used_colours.remove(d1)
                used_colours.remove(d2)
                used_colours.append(c1)
                used_colours.append(c2)

    if stuck==True:
        print 'no possible switches for factorization:'
        print rainbow
    
    return [achieved, seen_rainbows]


def sort_rainbow_by_colours(n, new_rainbow):
    new_rainbow_colours =  [new_rainbow[i][2] for i in range(n-1)]
    sorted_colours = sorted(range(n-1), key = lambda i: new_rainbow_colours[i])
    sorted_rainbow = [0 for _ in range(2*n-2)]

    for i in range(n-1):
        idx = sorted_colours[i]
        if new_rainbow[idx][0]<new_rainbow[idx][1]:
            sorted_rainbow[2*i]=new_rainbow[idx][0]
            sorted_rainbow[2*i+1]=new_rainbow[idx][1]
        else:
            sorted_rainbow[2*i]=new_rainbow[idx][1]
            sorted_rainbow[2*i+1]=new_rainbow[idx][0]
    sorted_rainbow = tuple(sorted_rainbow)
    return sorted_rainbow


### switch corner elements
### forbidden moves: 
###     1. nothing is connected to zero (nothing sums up to 0)
###     2. no diagonal elements
###     3. no repeats (rainbow has all distinct elts)    
def switch_graph(n, G, all_rainbows, graph, V):
       
    for rainbow in all_rainbows:
    
        sorted_original = sort_rainbow_by_colours(n,rainbow)
        used_colours = [rainbow[i][2] for i in range(n-1)]
            
        for comb in Combinations(n-1, 2):
            ## new colours
            x1,y1,c1 = rainbow[comb[0]]
            x2,y2,c2 = rainbow[comb[1]]
            
            new_options = [[[x1,y1],[x2,y2]],[[x1,y1],[y2,x2]],[[y1,x1],[x2,y2]],[[y1,x1],[y2,x2]]]
            for opt in new_options:
                a1,b1 = opt[0]
                a2,b2 = opt[1]
                d1 = G[a1][b2]
                d2 = G[a2][b1]
               
                if (d1!=0) and (d2!=0) and (d1!=d2) and (((d1 not in used_colours) and (d2 not in used_colours)) or ((d1 in [c1,c2]) and (d2 in [c1,c2]) )): #(a1!=b2) and (a2!=b1) and 

                    new_rainbow = []
                    for i in range(n-1):
                        if i not in comb:
                            new_rainbow.append(rainbow[i])
                    new_rainbow = new_rainbow+[[a1,b2,d1], [a2,b1,d2]]

                    sorted_rainbow = sort_rainbow_by_colours(n,new_rainbow)

                    ### update the graph
                    idx1 = V[sorted_original]
                    idx2 = V[sorted_rainbow]
                    graph.add_edge([idx1,idx2])
                        

  
def switch_graph_no_restrictions(n, G, all_rainbows, graph, V):
       
    for rainbow in all_rainbows:
    
        sorted_original = sort_rainbow_by_colours(n,rainbow)
        used_colours = [rainbow[i][2] for i in range(n-1)]
            
        for comb in Combinations(n-1, 2):
            ## new colours
            x1,y1,c1 = rainbow[comb[0]]
            x2,y2,c2 = rainbow[comb[1]]
            
            new_options = [[[x1,y1],[x2,y2]],[[x1,y1],[y2,x2]],[[y1,x1],[x2,y2]],[[y1,x1],[y2,x2]]]
            for opt in new_options:
                a1,b1 = opt[0]
                a2,b2 = opt[1]
                d1 = G[a1][b2]
                d2 = G[a2][b1]

                new_rainbow = []
                for i in range(n-1):
                    if i not in comb:
                        new_rainbow.append(rainbow[i])
                new_rainbow = new_rainbow+[[a1,b2,d1], [a2,b1,d2]]

                sorted_rainbow = sort_rainbow_by_colours(n,new_rainbow)

                ### update the graph
                idx1 = V[sorted_original]
                idx2 = V[sorted_rainbow]
                graph.add_edge([idx1,idx2])
                        



                        

#####################################################################################
########################### Hall's algorithm ########################################
#####################################################################################

##########
### Modified Hall's algorithm for sums (instead of differences)
###
### Inputs:
### n := number of elements, labeled from 0 to n-1
### G := group multiplicaiton table (symmetric)
### targets := set of targets which sums up to 0
###
### Output:
### perm := permutation given as two lists of n elements
##########
# one switch  
def update_perm(perm, curr_t, b, idx, G):
    
    a1 = perm[0][idx[0]]
    a2 = perm[0][idx[1]]
    c1 = perm[1][idx[0]]
    c2 = perm[1][idx[1]]
    
    b1 = b[0]
    b2 = b[1]
    
    good = False
    
    while not good:
       
        if G[a1][c1]==b1:
            perm[1][idx[0]]=c1
            curr_t[idx[0]]=b1
            perm[1][idx[1]]=c2
            curr_t[idx[1]]=b2 
            good = True
        elif G[a1][c1]==b2:
            perm[1][idx[0]]=c1
            curr_t[idx[0]]=b2
            perm[1][idx[1]]=c2
            curr_t[idx[1]]=b1 
            good = True
        elif G[a1][c2]==b1:
            perm[1][idx[0]]=c2
            curr_t[idx[0]]=b1
            perm[1][idx[1]]=c1
            curr_t[idx[1]]=b2 
            good = True
        elif G[a1][c2]==b2:
            perm[1][idx[0]]=c2
            curr_t[idx[0]]=b2
            perm[1][idx[1]]=c1
            curr_t[idx[1]]=b1 
            good = True        
        else:
            a_new = G[c1].index(b1)
            idx_new = perm[0].index(a_new)
            c_new = perm[1][idx_new]
            perm[1][idx_new]=c1
            b_new = curr_t[idx_new] 
            curr_t[idx_new] = b1
            b1 = b_new
            c1 = c2
            c2 = c_new
        
         
    
    
# whole algorithm   
def Hall_algorithm(n, G, targets):
    perm = [[i for i in range(n)], [i for i in range(n)]]
    curr_t = [G[i][i] for i in range(n)]
    
    for i in range(n-1):
        
        ### find the indices in the permutation which 
        ### already give us the targets 0 to i-1
        used = [0 for _ in range(n)]
        for j in range(i):
            idx = 0
            while (curr_t[idx]!=targets[j]) or (used[idx]==1):
                idx += 1
            used[idx] = 1
        
        idx1 = 0
        while used[idx1]==1:
            idx1 += 1
        idx2 = idx1+1
        while used[idx2]==1:
            idx2 += 1
        
        if (curr_t[idx1]!=targets[i]) and (curr_t[idx2]!=targets[i]):

            b_new = targets[i]
            sum_curr = G[curr_t[idx1]][curr_t[idx2]]

            w = G[b_new].index(sum_curr)
            b = [w, b_new] ## two new b's 

            update_perm(perm, curr_t, b, [idx1, idx2], G)

    return [perm, curr_t]
        
def shift_permutation(perm, curr_t, v):
    
    ### move target 0 to position 0,0
    idx = 0
    while curr_t[idx]!=0:
        idx += 1
    top = perm[0][idx]
    bott = perm[1][idx]
    
    for i in range(v):
        perm[0][i] = (perm[0][i]-top)%v
        perm[1][i] = (perm[1][i]-bott)%v
        
    ### rotate and sort 
    indices = [i[0] for i in sorted(enumerate(curr_t), key = lambda x:x[1])]
    
    new_perm = [[perm[0][i]  for i in indices], [perm[1][i]  for i in indices]]
    new_curr_t = [curr_t[i] for i in indices]
    return [new_perm, new_curr_t] 
        
                
                        
    
