# mostly translations of chevie/init.g and chevie/tbl/compat3.g
module Chevie

using ..Gapjm
export CHEVIE, chevieget, chevieset, getchev

const CHEVIE=Dict{Symbol,Any}(
 :compat=>Dict(:MakeCharacterTable=>x->x,
               :ChangeIdentifier=>function(tbl,n)tbl[:identifier]=n end),
 :info=>false
)

CHEVIE[:compat][:AdjustHeckeCharTable]=function(tbl,param)
  r=eachindex(tbl[:classtext])
  for i in r 
    f=prod(-last.(param[tbl[:classtext][i]]))
    for j in r tbl[:irreducibles][j][i]*=f end
  end
end

function chevieget(t::Symbol,w::Symbol)
  get!(CHEVIE[t],w)do
    if CHEVIE[:info] println("CHEVIE[$t] has no $w") end
  end
end

chevieget(t::String,w::Symbol)=chevieget(Symbol(t),w)

chevieset(t::Symbol,w::Symbol,o)=get!(CHEVIE,t,Dict{Symbol,Any}())[w]=o

function chevieset(t::Vector{String},w::Symbol,f::Function)
  println("set ",join(t,",")," $w")
  for s in t chevieset(Symbol(s),w,f(s)) end
end

function field(t::TypeIrred)
  if haskey(t,:orbit)
    phi=t.twist
    orderphi=order(t.twist)
    t=t.orbit[1]
  else
    orderphi=1
  end
  s=t.series
  if s in [:A,:B,:D] 
     if orderphi==1 return (s,PermRoot.rank(t))
     elseif orderphi==2 
       if s==:B return (Symbol(2,:I),4)
       else return (Symbol(2,s),PermRoot.rank(t))
       end
     elseif orderphi==3 return (Symbol("3D4"),)
     end
  elseif s in [:E,:F,:G]
    if orderphi==1 return (Symbol(s,PermRoot.rank(t)),) 
    elseif s==:G return (Symbol(2,:I),6)
    else return (Symbol(orderphi,s,PermRoot.rank(t)),) 
    end
  elseif s==:ST 
    if haskey(t,:ST)
      if orderphi!=1 return (Symbol(orderphi,"G",t.ST),)
      elseif 4<=t.ST<=22 return (:G4_22,t.ST)
      else return (Symbol("G",t.ST),)
      end
    elseif orderphi!=1
      return (:timp, t.p, t.q, t.rank, phi)
    else
      return (:imp, t.p, t.q, t.rank)
    end
  elseif s==:I return (orderphi==1 ? s : Symbol(2,s),t.bond)
  else return (Symbol(s,PermRoot.rank(t)),) 
  end
end

# functions whose result depends on cartanType
const needcartantype=Set([:Invariants,
                          :PrintDiagram,
                          :ReflectionName,
                          :UnipotentClasses,
                          :WeightInfo,
                          :CartanMat])

function getchev(t::TypeIrred,f::Symbol,extra...)
  d=field(t)
# println("d=$d f=$f extra=$extra")
  o=chevieget(d[1],f)
  if o isa Function
#   o(vcat(collect(d)[2:end],collect(extra))...)
    if haskey(t,:orbit) t=t.orbit[1] end
    if haskey(t,:cartanType) && f in needcartantype
#     println("args=",(d[2:end]...,extra...,t.cartanType))
      o(d[2:end]...,extra...,t.cartanType)
    else o(d[2:end]...,extra...)
    end
  else o
  end
end

function getchev(W,f::Symbol,extra...)
  [getchev(ti,f::Symbol,extra...) for ti in refltype(W)]
end

end
