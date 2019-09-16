library(RSelenium)
library(rvest)
remDr <- rsDriver(
  port=4567L,
  browser = "firefox"
)

rd<-remDr[["client"]]
rd$open()
rd$navigate("http://www.domicilios.com/bogota")
Sys.sleep(3)
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



rd$findElements(using = "class", value = "a")

so<-rd$getPageSource()

rd$close()

web<- read_html(as.character(so))

restaurantsName<-html_nodes(web,'.name-desktop .name')%>%html_text
link1<-html_nodes(web,'.list-open-establishments-container a')%>%html_attr('href')
link2<-html_nodes(web,'.list-closed-establishments-container a')%>%html_attr('href')
links<-c(link1,link2)
categories<-html_nodes(web,'.name-desktop .categories')%>%html_text
time_delivery<-html_nodes(web,'.delivery-time .column-item_description')%>%html_text
min_order<-html_nodes(web,'.min-order-value .column-item_description')%>%html_text
ship<-html_nodes(web,'.shipping .column-item_description')%>%html_text
total_coments<-html_nodes(web,'.name-desktop .reviews')%>%html_text

print(restaurantsName)
print(links)

df<-data.frame(restaurantsName,categories,time_delivery,min_order,ship,total_coments,links)
#fileName<-paste0("restaurantes_",as.character.Date(Sys.time()),".csv")
write.csv(df, file='restaurantes_.csv')
