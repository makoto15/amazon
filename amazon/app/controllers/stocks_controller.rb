class StocksController < ApplicationController
    layout 'amazon'
    def create
        #if amount variable is not an integer
        if (params[:amount] && (/[^0-9]/ =~ params[:amount]))
            render action: 'error' and return
        end
        # if price variable is not an integer
        if (params[:price] && (/[^0-9]/ =~ params[:price]))
            render action: 'error' and return
        end

        #when function variable was deleteall
        if params[:function] == 'deleteall'
            Stock.delete_all
            sale = Sale.first
            sale.sum = 0
            sale.save 
        
        #when function variable was addstock
        elsif params[:function] == 'addstock'
            #if name variable exists in stock db
            l = params[:name].size.to_s
            if stock = Stock.find_by(name: params[:name].unpack('c'+l).join(','))
                #if amount variable exists
                if params[:amount]
                    stock.amount += params[:amount].to_i
                    stock.save
                #if amount variable does not exists
                else
                    stock.amount += 1
                    stock.save
                end
            #if name variable does not exists in stock db
            else
                #if amount variable exists
                if params[:amount]
                    stock = Stock.new(name: params[:name].unpack('c'+l).join(','), amount: params[:amount])
                    stock.save
                #if amount variable does not exists
                else
                    stock = Stock.new(name: params[:name].unpack('c'+l).join(','), amount: params[:amount])
                    stock.save
                end
            end

        #when function variable was checkstock
        elsif params[:function] == 'checkstock'
            @stocks = Stock.all
            @name = params[:name]
            render action: 'checkstock' and return
        
        #when funcion variable was sell
        elsif params[:function] == 'sell'
            l = params[:name].size.to_s
            stock = Stock.find_by(name: params[:name].unpack('c'+l).join(','))
            if params[:amount]
                if params[:price]
                    stock.amount -= params[:amount].to_i
                    sale = Sale.first
                    sale.sum += params[:price].to_i * params[:amount].to_i
                    stock.save
                    sale.save
                else
                    stock.amount -= params[:amount].to_i
                    stock.save
                end
            else
                if params[:price]
                    stock.amount -= 1
                    sale = Sale.first
                    sale.sum += params[:price].to_i
                    stock.save
                    sale.save
                else
                    stock.amount -= 1
                    stock.save
                end
            end
        elsif params[:function] == 'checksales'
            @sale = Sale.first
            render action: 'checksales' and return
        else
            render action: 'error' and return 
        end
    end

end
