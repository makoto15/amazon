class StocksController < ApplicationController
    layout 'amazon'
    def create
        #if amount variable is not an integer
        if (params[:amount] && (/[^0-9]/ =~ params[:amount]))
            render action: 'error'
        end
        # if price variable is not an integer
        if (params[:price] && (/[^0-9]/ =~ params[:price]))
            render action: 'error'
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
            if stock = Stock.find_by(name: params[:name])
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
                    stock = Stock.new(name: params[:name], amount: params[:amount])
                    stock.save
                #if amount variable does not exists
                else
                    stock = Stock.new(name: params[:name], amount: params[:amount])
                    stock.save
                end
            end

        #when function variable was checkstock
        elsif params[:function] == 'checkstock'
            @stocks = Stock.all.order(name: 'ASC')
            @name = params[:name]
            render action: 'checkstock'
        
        #when funcion variable was sell
        elsif params[:function] == 'sell'
            stock = Stock.find_by(name: params[:name])
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
            render action: 'checksales'
        else
            render action: 'error'
        end
    end

end
