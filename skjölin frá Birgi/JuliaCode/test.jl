#=
test:
- Julia version: 
- Author: Ingolfur
- Date: 2023-02-01
=#
#Gera funds töflu
using XLSX, DataFrames

sheet_name = "Gögn"
println(1)
path = "C:/Users/Ingolfur/Documents/GitHub/engx-project-group20/skjölin frá Birgi/Files/Arsreikningabok-2021.xlsx"

println(2)
xf = XLSX.readxlsx(path)

#Return the values in a column, starting in first row and until first empty cell occurs
function read_column(sheet, firstrow, col)
    res = []
    row = firstrow
    while !ismissing(sheet[row,col])
        push!(res,sheet[row,col])
        row+=1
    end
    return res
end

println(3)
sheet_name = "Gögn"

println(4)
sheet = xf[sheet_name]
println(5)
firstrow = 2
col = 2
shortname = read_column(sheet, firstrow, col)
println(6)
col = 3
fundname = read_column(sheet, firstrow, col)
col = 4
subfundname = read_column(sheet, firstrow, col)
println(7)
col = 5
subfundtype = read_column(sheet, firstrow, col)
col = 1
println(8)
fullname = read_column(sheet, firstrow, col)
println(9)
rawdata = DataFrame(fundname = fundname, shortname = shortname, subfundname = subfundname,subfundtype = subfundtype, fullname = fullname)
println(rawdata)
println(10)

funds = combine(groupby(rawdata,[:fundname,:shortname]),nrow)[:,[:fundname,:shortname]]

#funds.fundid .= collect(1:nrow(funds))

funds

#Add regex - v1.
#Create a version and test it against the fundnames and short names
myregex = r"Lífsval"
#myregex = r"(L|l)íf[a-z. ]*Versl"
regex_expressions = ["Almenni","Arion","Birta","Brú","(Eftirl[a-z. óð]*flug|FÍA)","Festa",
                    "Frjálsi","Gildi","Íslandsbanki","Íslenski","Kvika","Landsbankinn","bænda",
                    "bankam","Rang","Akureyr","Búnaðar","(Reykjav|Rvk)","(ríkis|LSR|Lsr)",
                    "(Tannl|tannl)","((L|l)íf[a-z. óð]*Versl|(L|l)íf[a-z. óð]*versl)",
                    "(L|l)íf[a-z.óð]+ (V|v)estm","Lífsval",
                    "((L|l)ífsverk|(L|l)íf[a-z. óð]*verkf)","Söfnunar","Stapi"]

for fund in funds.fundname
    m = match(myregex, fund)
    if isnothing(m)
        #println("$fund, No match!")
    else
        println("$fund, Fund Match! , $(m.match)")
    end
end

for fund in funds.shortname
    m = match(myregex, fund)
    if isnothing(m)
        #println("$fund, No match!")
    else
        println("$fund, Short Match! , $(m.match)")
    end
end

#funds.regexp .= regex_expressions
funds

#Ok, gera nuna funds div
rawdata

subfunds = combine(groupby(rawdata,[:fundname,:subfundname,:subfundtype]),nrow)[:,[:fundname,:subfundname,:subfundtype]]

#subfunds.subfundid .= collect(1:nrow(subfunds))

#Map the type to english
subfundtype_map = Dict("Séreign" => "Private", "Samtrygging" => "Coinsurance")
transform!(subfunds, :subfundtype => ByRow(x -> subfundtype_map[x]) => :subfundtype)

#Returns the ID of the fundname using regex - errors if there is more than one match
function get_fund_id(fundname::String,funds::DataFrame)
    found = false
    fundid = 0
    official_fund_name = ""
    for row in eachrow(funds)
        myregex = Regex(row[:regexp])
        m = match(myregex,fundname)
        if !isnothing(m)
            if found
                error("Hi man! Two matches for a regex! $official_fund_name and $(row[:fundname])")
            else
                fundid = row[:fundid]
                official_fund_name = row[:fundname]
                found = true
            end
        end
    end
    if !found
        error("$fundname is a new fund, need to register in funds db!")
    end
    return fundid
end

#Use the funds dataframe that already exists
get_fund_id(fundname::String) = get_fund_id(fundname,funds)
println("hjalp")
transform!(subfunds, :fundname => ByRow(get_fund_id) => :fundid)
subfunds

