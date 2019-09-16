library(RSelenium)
library(rvest)

rest <- read.csv("restaurantes.csv")

linkvec<-rest$links
counter=1
coments<-c()
dataprev<-matrix()

remDr <- rsDriver(
  port=4567L,
  browser = "firefox"
)

rd<-remDr[["client"]]


for (links in linkvec) {

data_rest<-rest[counter,2:6]
datatemp<-data_rest 


link<-paste0("https://domicilios.com",links)

rd$open()

rd$navigate(link)


commentTab<-rd$findElement(using = "css", value = ".comment-tab")
commentTab$clickElement()

x=1000
rd$executeScript("window.scrollTo(0,document.body.scrollHeight -2000);")
rd$executeScript("window.scrollTo(0,0);")

last_height = 0
repeat {
  code<-paste0("window.scrollTo(0,",x,");")
  rd$executeScript(code)
  
  x= x + 800
  
  new_height = rd$executeScript("return document.body.scrollHeight")
  Sys.sleep(3)
  if(unlist(last_height) == unlist(new_height)) {
    break
  } else {
    last_height = new_height
  }
}

rd$findElements(using = "class", value = "p")


so<-rd$getPageSource()
rd$close()

web<- read_html(as.character(so))

com<-html_nodes(web,'.comment-info-text')%>%html_text

w<-length(com)-1

for(i in 1:w){
  datatemp<-rbind(datatemp,data_rest)
}

if(dim(dataprev)[1]== 1){
  dataprev<-datatemp
}
else {
  dataprev<-rbind(dataprev,datatemp)
}

coments<-c(coments,com)

counter<-counter+1
}
rd$close()

dataprev<-cbind(dataprev,coments)

df<-data.frame(dataprev)
write.csv(df, file='restaurantes_and_coments.csv')
