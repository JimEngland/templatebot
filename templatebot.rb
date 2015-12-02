require 'httparty'
require 'rubygems'
require 'json'
require 'enumerator'
require 'fastimage'
require 'sinatra'
require 'htmlentities'

get '/new' do
  erb :new, :layout => :template
end


get '/' do
  erb :index, :layout => :template
end

post '/' do

  #Get the form fields
  page_title = params[:title]
  page_description = params[:description]
  cta_title = params[:cta_title]
  cta_url = params[:cta_url]
  show_product_titles = params[:show_product_titles]
  show_product_prices = params[:show_product_prices]
  show_discount = params[:show_discount]

  #Conditionals
  if !page_description.empty?
    description = "true"
  else
    description = "false"
  end
  if !cta_title.empty?
    cta = "true"
  else
    cta = "false"
  end
  if !show_product_titles.nil?
    no_title = "false"
  else
    no_title = "true"
  end
  if !show_product_prices.nil?
    no_price = "false"
  else
    no_price = "true"
  end
  if !show_discount.nil?
    discount = "true"
  else
    discount = "false"
  end

  #Get the SKUs from Sheetsu
  response = HTTParty.get("https://sheetsu.com/apis/e487ee70")
  data = JSON.parse(response.body)

  @text_output = ""
  @html_output = ""

  @text_output << (<<-EOT)
<%PageTitle%>
<%PageDescription%>

  EOT

  @html_output << (<<-EOT)
    <!-- Products -->
      <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#ffffff">
        <tr>
          <td>
            <div style="font-size:0pt; line-height:0pt; height:27px"><img src="https://static.bezar.com/email/empty.gif" width="1" height="27" style="height:27px" alt="" /></div>


            <table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td class="content-spacing" style="font-size:0pt; line-height:0pt; text-align:left" width="20"></td>
                <td>
  EOT

  if cta == "true"                        
    @html_output << (<<-EOT)
      <a href="<%CTAURL%>" style="color:#221e1f; font-family:Arial; font-size:21px; line-height:22px; text-align:center; text-decoration:none">
        <div class="h2-black" style="color:#221e1f; font-family:Arial; font-size:21px; line-height:22px; text-align:center; font-weight:bold; letter-spacing:2px;text-transform:uppercase;text-decoration:none"><%PageTitle%></div>
    EOT
    if description == "true"
      @html_output << (<<-EOT)
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td width="40"></td>
            <td width="560">
              <div style="font-size:0pt; line-height:0pt; height:6px"><img src="https://static.bezar.com/email/empty.gif" width="1" height="6" style="height:6px" alt="" /></div>
              <div style="color:#888;font-family:Arial; font-size:18px; line-height:24px; text-align:center;"><%PageDescription%></div>
            </td>
            <td width="40"></td>
          </tr>
        </table>
      EOT
    end
    @html_output << (<<-EOT)
      </a>
    EOT
  else
    @html_output << (<<-EOT)
      <div class="h2-black" style="color:#221e1f; font-family:Arial; font-size:21px; line-height:22px; text-align:center; font-weight:bold; letter-spacing:2px;text-transform:uppercase;text-decoration:none"><%PageTitle%></div>
    EOT
    if description == "true"
      @html_output << (<<-EOT)
        <div style="font-size:0pt; line-height:0pt; height:10px"><img src="https://static.bezar.com/email/empty.gif" width="1" height="10" style="height:10px" alt="" /></div>
        <div style="color:#888;font-family:Arial; font-size:18px; line-height:24px; text-align:center;"><%PageDescription%></div>
      EOT
    end
  end

  @html_output << (<<-EOT)
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td align="center">
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
  EOT

  data["result"].each_with_index do |item,count|

    #Get Variables From Spreadsheet Results
    product_url = item["link"]
    product_image_url = item["image_link"]
    product_size = FastImage.size(product_image_url)

    if product_size.nil?
      product_image_orientation = "Landscape"      
    else 
      if product_size[0] > product_size[1]
        product_image_orientation = "Landscape"
      else
        product_image_orientation = "Portrait"
      end      
    end

    product_title = item["title"]
    product_designer = item["brand"]
    is_sale_price = item["sale_price"]

    if is_sale_price.empty?
      product_price = item["price"]
      product_price.slice! " USD"
      product_price = product_price[0...-3]   
      product_strikethrough_price = ''
    else
      product_price = item["sale_price"]
      product_price.slice! " USD"
      product_price = product_price[0...-3]
      product_strikethrough_price = item["price"]
      product_strikethrough_price.slice! " USD"
      product_strikethrough_price = product_strikethrough_price[0...-3]    
    end

    discount_percentage = item["discount"]
    puts discount_percentage

    @text_output += "<%Designer%>\n<%URL%>\n\n"


    if count %3 != 0      
      @html_output << (<<-EOT)
        <td class="column" width="25">
          <div style="font-size:0pt; line-height:0pt; height:20px">
            <img src="https://static.bezar.com/email/empty.gif" width="1" height="20" style="height:20px" alt="" />
          </div>
        </td>
      EOT
    elsif count % 3 == 0
      @html_output << (<<-EOT)
            </tr>
              </table>
            </td>
          </tr>
        </table>
        <div style="font-size:0pt; line-height:0pt; height:20px"><img src="https://static.bezar.com/email/empty.gif" width="1" height="20" style="height:20px" alt="" /></div>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td align="center">
              <table border="0" cellspacing="0" cellpadding="0">
                <tr>
      EOT
    end

    @html_output << (<<-EOT)
      <td width="180" valign="top" class="column" align="center">
        <!-- START Recommended Product -->
        <table border="0" cellpadding="0" cellspacing="0" width="180">
          <tr>
            <td class="item-image" height="205" valign="middle">
              <div class="img-center" style="font-size:0pt; line-height:0pt; text-align:center;">
                <a href="<%URL%>" target="_blank">
    EOT

    
    if product_image_orientation == "Landscape"
     
      @html_output << (<<-EOT)
        <img alt="" border="0" src="<%ImageURL%>" width="180"/>
      EOT
    else
      @html_output << (<<-EOT)
        <img alt="" border="0" src="<%ImageURL%>" height="180"/>
      EOT
    end  

    @html_output << (<<-EOT) 
            </a>
              </div>
              <div style="font-size:0pt; line-height:0pt; height:15px">
                <img alt="" height="15" src="https://static.bezar.com/email/empty.gif" style="height:15px" width="1"/>
              </div>
            </td>
          </tr>
          <tr>
            <td>
              <div class="h5" style="color:#9f9c96; font-family:Arial; font-size:11px; line-height:15px; text-align:center; text-transform:uppercase;"><%Designer%></div>
              <div style="font-size:0pt; line-height:0pt; height:10px">
                  <img alt="" height="10" src="https://static.bezar.com/email/empty.gif" style="height:10px" width="1"/>
              </div>
    EOT

    if no_title == "false"
      @html_output << (<<-EOT)
              <div class="h4" style="color:#2d2829; font-family:Arial; font-size:13px; line-height:16px; text-align:center; font-weight:bold; letter-spacing:1px; text-transform:uppercase;"><%Title%></div>
              <div style="font-size:0pt; line-height:0pt; height:7px">
                <img alt="" height="7" src="https://static.bezar.com/email/empty.gif" style="height:7px" width="1"/>
              </div>
      EOT
    end

    if no_price == "false"
      @html_output << (<<-EOT)
              <div class="h4" style="color:#2d2829; font-family:Arial; font-size:13px; line-height:16px; text-align:center; font-weight:bold;letter-spacing:1px"><span class="h4" style="color:#2d2829; font-family:Arial; font-size:13px; line-height:16px; letter-spacing:1px; text-align:center; font-weight:bold; letter-spacing:1px">$<%Price%></span>
      EOT
      if product_strikethrough_price.to_s != ''
        @html_output << (<<-EOT)
          <span class="h4" style="color:#B2B0AC; font-family:Arial; font-size:13px; line-height:16px; text-align:center; font-weight:bold; letter-spacing:1px; text-decoration: line-through;">$<%StrikethroughPrice%></span>
        EOT
      end
      @html_output << (<<-EOT)
        </div>
      EOT
    else
      if discount == "true"
        @html_output << (<<-EOT)
              <div class="h4" style="color:#2d2829; font-family:Arial; font-size:13px; line-height:16px; text-align:center; font-weight:bold;letter-spacing:1px"><span class="h4" style="color:#2d2829; font-family:Arial; font-size:13px; line-height:16px; letter-spacing:1px; text-align:center; font-weight:bold; letter-spacing:1px"><%Discount%> OFF</span>
        EOT
      end
    end

    @html_output << (<<-EOT)              
          </td>
        </tr>
      </table>
      <!-- END Recommended Product -->
    </td>
    EOT

    #Insert Variables into Text
    @text_output = @text_output.gsub('<%URL%>', product_url )
    @text_output = @text_output.gsub('<%Designer%>', product_designer )

    #Insert Variables into HTML
    @html_output = @html_output.gsub('<%URL%>', product_url )
    @html_output = @html_output.gsub('<%ImageURL%>', product_image_url )
    @html_output = @html_output.gsub('<%Title%>', product_title )
    @html_output = @html_output.gsub('<%Designer%>', product_designer )
    @html_output = @html_output.gsub('<%Price%>', product_price )
    @html_output = @html_output.gsub('<%StrikethroughPrice%>', product_strikethrough_price )
    @html_output = @html_output.gsub('<%Discount%>', discount_percentage )
    
  end

  @text_output << (<<-EOT)
<%CTATitle%>
<%CTAURL%>

  EOT

  @html_output << (<<-EOT)
                      </tr>
                    </table>
                  </td>
                </tr>
              </table>
  EOT

  if cta == "true"
    @html_output << (<<-EOT)
                          <table width="100%" border="0" cellpadding="0" cellspacing="0">
                            <tr>
                              <td height="30"></td>
                            </tr>

                            <tr>
                              <td align="center">
                                <a href="<%CTAURL%>" class="mobile-button white-button" style='-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-family:Helvetica, Verdana, sans-serif;text-decoration:none;font-size:16px;font-weight:bold;text-decoration:none;text-transform:uppercase;border-radius:3px;-webkit-border-radius:3px;-moz-border-radius:3px;display:inline-block;letter-spacing:2px;background-color:#221e1f;border-top:15px solid #221e1f;border-bottom:15px solid #221e1f;border-left:15px solid #221e1f;border-right:15px solid #221e1f;color:white;'><%CTATitle%></a>
                              </td>
                            </tr>
                          </table>
    EOT
  end

  @html_output << (<<-EOT)
                          </td>
                          <td class="content-spacing" style="font-size:0pt; line-height:0pt; text-align:left" width="20"></td>
                        </tr>
                      </table>                      

                      <div style="font-size:0pt; line-height:0pt; height:37px"><img src="https://static.bezar.com/email/empty.gif" width="1" height="37" style="height:37px" alt="" /></div>

                    </td>
                  </tr>
                </table>
                <!-- END Products -->
  EOT

  #Insert Variables into HTML
  @html_output = @html_output.gsub('<%PageTitle%>', page_title )
  @html_output = @html_output.gsub('<%PageDescription%>', page_description )
  @html_output = @html_output.gsub('<%CTATitle%>', cta_title )
  @html_output = @html_output.gsub('<%CTAURL%>', cta_url )

  @text_output = @text_output.gsub('<%PageTitle%>', page_title )
  @text_output = @text_output.gsub('<%PageDescription%>', page_description )
  @text_output = @text_output.gsub('<%CTATitle%>', cta_title )
  @text_output = @text_output.gsub('<%CTAURL%>', cta_url )

  @html_view = @html_output

  #Encode HTML Results
  coder = HTMLEntities.new
  @html_output = coder.encode(@html_output, :basic)



  erb :results, :layout => :template
end

