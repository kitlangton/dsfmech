require 'capybara'
require 'capybara-webkit'
require 'capybara/dsl'
require 'nokogiri'
require 'capybara/poltergeist'

Capybara.run_server = false
Capybara.current_driver = :webkit
Capybara.app_host = "https://coloredge.myprintdesk.net/DSF"

module DSF
  class Undertaker
    include Capybara::DSL

    def initialize
      @file = File.new(__dir__ + "/dsflog.txt", "w")
    end

    def setup
      visit "https://coloredge.myprintdesk.net/DSF/Login.aspx"
      fill_in "ctl00$ctl00$C$W$_loginWP$_myLogin$_userNameTB", with: "administrator"
      fill_in "ctl00$ctl00$C$W$_loginWP$_myLogin$_passwordTB", with: "cTKQ&sial4xe"
      click_button "Login"

      visit_home
      each_link
    end

    def visit_home
      visit "https://coloredge.myprintdesk.net/DSF/Companies/macy's%20hotline/storefront.aspx?SITEGUID=03c4a9c9-fabd-431f-be73-f7cf41734a70"
      visit "https://coloredge.myprintdesk.net/DSF/storefront.aspx"
      select "50", from: "ctl00$ctl00$C$W$_FeaturedCategoryDisplayControlWP$_FeaturedCategories$PagerUI1$PageSizesDropDown"
      sleep 3
    end

    def product?(col)
        col.traverse do |node|
          if node['id']
            return node['href'] if node['id'].match(/ProductItem_ManageIt/)
          end
        end
        false
    end

    def each_link(path = "")
      my_url = current_url
      page = Nokogiri::HTML(body)
      sections = page.css(".ctr_small_vertical")
      sections.each do |col|
        if product_link = product?(col)
          product_name = col.css('.producttitlelinkcolor-link')[0].text
          my_path = path + "/" + product_name

          # visit "https://coloredge.myprintdesk.net/DSF/#{product_link}"
          # product = Nokogiri::HTML(body)
          # full_name = product.css("#ctl00_ctl00_C_M_ctl00_W_ctl01__Name")[0]['value']

          puts "#{my_path}"
          # p full_name
          # puts "ID: #{full_name}"
          @file.puts "PRODUCT: #{my_path}"
        else
          product_name = col.css('.producttitlelinkcolor-link')[0].text
          my_path = path + "/" + product_name
          click_link product_name
          puts "#{my_path}/"
          each_link(my_path)
        end
        if current_url != my_url
          visit my_url
        end
      end
      if current_url != my_url
        visit my_url
      end
    end

  end
end

DSF::Undertaker.new.setup
