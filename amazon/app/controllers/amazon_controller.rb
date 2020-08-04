class AmazonController < ApplicationController
    @@stocker = {}
    @@sell = 0
    layout 'amazon'
    def index
    end
    
    def secret
        basic_secret =   
            authenticate_or_request_with_http_basic do |username, password|
                if !(username == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD'])
                    render action: 'error'
                else
                    render action: 'secret'
                end
            end
    end

    def calc
        calculate = params.keys
        calculate.delete('controller')
        calculate.delete('action')
        calculate = calculate[0].dup
        if /[^0-9\*\/ -\(\)]/ =~ calculate
            render action: 'error_calc'
        else
            calculate.size.times do |i|
                if calculate[i] == " "
                    calculate[i] = "+"
                end
            end
            @answer = cal(calculate)
        end
    end

    def stocker
        if (params[:amount] && (/[^0-9]/ =~ params[:amount]))
            render action: 'error_calc'
        end
        if (params[:price] && (/[^0-9]/ =~ params[:price]))
            render action: 'error_calc'
        end
        if params[:function] == 'deleteall'
            @@stocker = {}
        elsif params[:function] == 'addstock'
            if @@stocker[params[:name]]
                if params[:amount]
                    @@stocker[params[:name]] += params[:amount].to_i
                else
                    @@stocker[params[:name]] += 1
                end
            else
                if params[:amount]
                    @@stocker[params[:name]] = params[:amount].to_i
                else
                    @@stocker[params[:name]] = 1
                end
            end
        elsif params[:function] == 'checkstock'
            @stocker = @@stocker
            @name = params[:name]
            render action: 'checkstock'
        elsif params[:function] == 'sell'
            if params[:amount]
                @@stocker[params[:name]] -= params[:amount].to_i
                @@sell += params[:amount].to_i * params[:price].to_i
            else
                @@stocker[params[:name]] -= 1
                @@sell += params[:price].to_i
            end
        elsif params[:function] == 'checksales'
            @sell = @@sell
            render action: 'checksales'
        else
            render action: 'error_calc'
        end
    end


    private

    def formula_to_infix(formula)
        infix_array = Array.new
        sign = "" # 単項演算子の符号を覚えておく変数
        may_sign = true # 単項演算子の符号が現れる可能性があるときtrue
        s = StringScanner.new(formula)
        while !s.eos?
          case
          when s.scan(/(\*|\/|\(|\))/)
            # ×、／、左括弧と右括弧の場合
            infix_array << s[1]
            may_sign = true
          when s.scan(/(\+|\-)/)
            # ＋と－の場合
            if may_sign then
              sign = s[1]
            else
              infix_array << s[1]
            end
          when s.scan(/(\d+)/)
            # 符号のついていない数値が見つかった場合
            infix_array << sign + s[1]
            sign = ""
            may_sign = false
          else
            raise "error #{s.rest}"
          end
        end
        infix_array
    end

    def infix_to_postfix(infix_array)
        output = Array.new
        ope_stack = Array.new
        infix_array.each { |token|
            if token == '(' then
                # 左括弧が見つかったらスタックへ覚えておく
                ope_stack.push(token)
            elsif token == ')' then
                while ope_stack.size > 0 do
                    ope = ope_stack.pop
                break if ope == '('
                    output << ope
                end
            elsif '*|/'.split('|').include?(token) then
                # ×と／が見つかったら、
                # ×と／が見つかるうちはスタックから取り出して出力してから、
                # スタックへ覚えておく
                while ope_stack.size > 0 && '*|/'.split('|').include?(ope_stack.last) do
                    ope = ope_stack.pop
                    output << ope
                end
                ope_stack.push(token)
            elsif '+|-'.split('|').include?(token) then
                # ＋と－が見つかったら、
                # ＋と－と×と／が見つかるうちはスタックから取り出して出力してから、
                # スタックへ覚えておく
                while ope_stack.size > 0 && '+|-|*|/'.split('|').include?(ope_stack.last) do
                    ope = ope_stack.pop
                    output << ope
                end
                ope_stack.push(token)
            elsif /(\-{0,1}\d+)/ =~ token then
                # 数値はそのまま出力
                output << token
            else
                printf "LINE#{__LINE__}: token error [#{token}] \n"
                raise "error #{token}"
            end
        }
        # スタックから全て取り出して出力
        while ope_stack.size > 0 do
            output << ope_stack.pop
        end
        output
    end

    def calc_postfix(postfix_array)
        stack = Array.new
        postfix_array.each { |token|
        case token
        when "+" then 
            r = stack.pop
            l = stack.pop
            stack.push(l + r)
        when "-" then 
            r = stack.pop
            l = stack.pop
            stack.push(l - r)
        when "*" then 
            r = stack.pop
            l = stack.pop
            stack.push(l * r)
        when "/" then 
            r = stack.pop
            l = stack.pop
            if r != 0 then
                stack.push(l / r)
            else
                # ゼロで割っちゃだめ。
                p postfix_array
                raise "divided by zero"
            end
        else
            stack.push(token.to_i)
        end
        }
        result = stack.pop
    end

    def cal(formula)
        infix_array = formula_to_infix(formula)
        postfix_array = infix_to_postfix(infix_array)
        result = calc_postfix(postfix_array)
    end



end
