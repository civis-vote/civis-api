require "razorpay"

class OrdersController < ApplicationController

    def create
        order = Razorpay::Order.create({amount: params[:amount], currency: params[:currency], receipt: 'order_2'})
        render json: order
    end
end
