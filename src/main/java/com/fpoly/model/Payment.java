package com.fpoly.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "PAYMENT")
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    // Đúng 1 trong 2 có giá trị: order (thanh toán đơn hàng) HOẶC subscription (mua gói hội
    // viên). VNPayController rẽ nhánh xử lý callback theo cột nào khác null.
    @OneToOne
    @JoinColumn(name = "order_id")
    private Order order;

    @ManyToOne
    @JoinColumn(name = "subscription_id")
    private UserSubscription subscription;

    @ManyToOne
    @JoinColumn(name = "payment_method_id")
    private PaymentMethod paymentMethod;

    @Column(name = "amount")
    private BigDecimal amount;

    // pending, paid, failed, waiting_verify
    @Column(name = "status")
    private String status;

    @Column(name = "transaction_ref")
    private String transactionRef;

    @Column(name = "paid_at")
    private LocalDateTime paidAt;

    @Column(name = "proof_image")
    private String proofImage;

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Order getOrder() { return order; }
    public void setOrder(Order order) { this.order = order; }

    public UserSubscription getSubscription() { return subscription; }
    public void setSubscription(UserSubscription subscription) { this.subscription = subscription; }

    public PaymentMethod getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(PaymentMethod paymentMethod) { this.paymentMethod = paymentMethod; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }

    public String getProofImage() { return proofImage; }
    public void setProofImage(String proofImage) { this.proofImage = proofImage; }
}
