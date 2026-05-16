using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.PlaceOrder;

public sealed class PlaceOrderCommandHandler : IRequestHandler<PlaceOrderCommand, OrderDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly IOrderRepository _orderRepository;
    private readonly ICurrentUser _currentUser;
    private readonly IPaymentService _paymentService;
    private readonly IInvoiceService _invoiceService;
    private readonly IUserRepository _userRepository;
    private readonly IPaymentRepository _paymentRepository;

    public PlaceOrderCommandHandler(
        ICartRepository cartRepository,
        IOrderRepository orderRepository,
        ICurrentUser currentUser,
        IPaymentService paymentService,
        IInvoiceService invoiceService,
        IUserRepository userRepository,
        IPaymentRepository paymentRepository)
    {
        _cartRepository = cartRepository;
        _orderRepository = orderRepository;
        _currentUser = currentUser;
        _paymentService = paymentService;
        _invoiceService = invoiceService;
        _userRepository = userRepository;
        _paymentRepository = paymentRepository;
    }

    public async Task<OrderDto> Handle(PlaceOrderCommand request, CancellationToken cancellationToken)
    {
        var cart = await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new ConflictException("Cannot place an order with an empty cart.");

        if (cart.Items.Count == 0)
            throw new ConflictException("Cannot place an order with an empty cart.");

        // 1. Calculate total amount
        var totalAmount = cart.Items.Sum(x => x.LineTotal) + request.DeliveryCharge;

        // 2. Prepare User/Customer context
        var user = await _userRepository.GetByIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new InvalidOperationException("User not found.");

        string? stripeCustomerId = user.StripeCustomerId;

        // 3. Handle card saving / customer preparation BEFORE payment
        // This prevents "PaymentMethod was previously used without being attached" error
        if (request.SaveCard)
        {
            if (string.IsNullOrEmpty(stripeCustomerId))
            {
                stripeCustomerId = await _paymentService.CreateCustomerAsync(user.Email, $"{user.FirstName} {user.LastName}");
                await _userRepository.UpdateStripeCustomerIdAsync(user.Id, stripeCustomerId!, cancellationToken);
            }

            // Attach method to customer before using it for payment
            await _paymentService.AttachPaymentMethodToCustomerAsync(request.PaymentMethodId, stripeCustomerId!);
            
            // Save to our DB
            var cardDetails = await _paymentService.GetPaymentMethodDetailsAsync(request.PaymentMethodId);
            var userCard = Domain.Identity.UserCard.Create(
                user.Id,
                request.PaymentMethodId,
                cardDetails.Brand,
                cardDetails.Last4,
                cardDetails.ExpMonth,
                cardDetails.ExpYear,
                true
            );
            await _paymentRepository.AddCardAsync(userCard, cancellationToken);
        }

        Console.WriteLine($"[Stripe] Processing payment for {totalAmount} GBP...");
        // 4. Process payment via Stripe
        (bool success, string transactionId, string errorMessage) = await _paymentService.ProcessPaymentAsync(
            totalAmount, 
            "gbp", 
            request.PaymentMethodId, 
            $"Order for User: {_currentUser.UserId}",
            stripeCustomerId,
            request.SaveCard ? "off_session" : null); // Pass setup instruction if saving

        if (!success)
        {
            Console.WriteLine($"[Stripe] Payment failed: {errorMessage}");
            throw new ConflictException($"Payment failed: {errorMessage}");
        }
        Console.WriteLine($"[Stripe] Payment successful. TransactionId: {transactionId}");

        // 3. Create order
        Console.WriteLine("[Order] Creating order in database...");
        var orderId = await _orderRepository.CreateFromCartAsync(
            _currentUser.UserId,
            request.DeliverySlotId,
            request.DeliveryAddress,
            request.DeliveryCharge,
            _currentUser.UserId,
            cancellationToken);

        Console.WriteLine($"[Order] Order created with ID: {orderId}. Clearing cart...");
        await _cartRepository.ClearAsync(_currentUser.UserId, _currentUser.UserId, cancellationToken);

        var order = await _orderRepository.GetByIdAsync(orderId, cancellationToken)
            ?? throw new InvalidOperationException("Order not found after creation.");

        // 4. Generate Invoice PDF (Run in background to avoid hanging the response)
        _ = Task.Run(async () =>
        {
            try
            {
                var fileName = $"invoice_{order.Id}_{DateTime.Now:yyyyMMddHHmmss}.pdf";
                
                // Using wwwroot/assets/invoices for easy access if the API serves static files
                var basePath = Directory.GetCurrentDirectory();
                var invoicePath = Path.Combine(basePath, "wwwroot", "assets", "invoices", fileName);
                
                Console.WriteLine($"[Invoice] Starting generation: {invoicePath}");
                await _invoiceService.GenerateInvoicePdfAsync(order, invoicePath);
                Console.WriteLine($"[Invoice] Generation successful: {invoicePath}");

                // Update order with the filename (not full path, we'll serve it from assets/invoices)
                await _orderRepository.UpdateInvoicePathAsync(order.Id, fileName, _currentUser.UserId);
                Console.WriteLine($"[Invoice] Database updated with fileName: {fileName}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[Invoice] Generation failed: {ex.Message}");
            }
        }, cancellationToken);

        return order;
    }
}
