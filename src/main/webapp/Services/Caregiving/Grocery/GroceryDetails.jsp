<jsp:include page="/auth/AuthCheck.jsp" />
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>

<%
String idParam = request.getParameter("id");

int companyId = Integer.parseInt(idParam);

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

// ================= FETCH PROVIDER ==================
PreparedStatement providerStmt = conn.prepareStatement(
    "SELECT c.name, c.delivery_fee, c.est_delivery_time, c.location, " +
    "IFNULL(AVG(r.rating),0) AS rating " +
    "FROM grocery_company c " +
    "LEFT JOIN grocery_review r ON c.id = r.company_id " +
    "WHERE c.id = ?"
);
providerStmt.setInt(1, companyId);
ResultSet provider = providerStmt.executeQuery();
provider.next();

double shippingFee = provider.getDouble("delivery_fee");

// ================= FETCH ITEMS =====================
PreparedStatement itemsStmt = conn.prepareStatement(
    "SELECT * FROM grocery_item WHERE company_id = ? AND is_available = 1"
);
itemsStmt.setInt(1, companyId);
ResultSet itemRs = itemsStmt.executeQuery();

// ================= FETCH DISCOUNTS =================
PreparedStatement discStmt = conn.prepareStatement(
    "SELECT d.* FROM grocery_company_discount cd " +
    "JOIN grocery_discount_rule d ON cd.rule_id = d.id " +
    "WHERE cd.company_id = ? AND d.is_active = 1 " +
    "ORDER BY d.min_order_amount ASC"
);
discStmt.setInt(1, companyId);
ResultSet discTemp = discStmt.executeQuery();

class Discount {
    int id; String name; String type;
    double amount; double minOrder;
    Timestamp start; Timestamp end;
    boolean stack;
}

ArrayList<Discount> discountList = new ArrayList<>();
while (discTemp.next()) {
    Discount d = new Discount();
    d.id = discTemp.getInt("id");
    d.name = discTemp.getString("name");
    d.type = discTemp.getString("type");
    d.amount = discTemp.getDouble("amount");
    d.minOrder = discTemp.getDouble("min_order_amount");
    d.start = discTemp.getTimestamp("start_date");
    d.end = discTemp.getTimestamp("end_date");
    d.stack = discTemp.getInt("is_stackable") == 1;
    discountList.add(d);
}

// ================= FETCH REVIEWS =================
PreparedStatement reviewStmt = conn.prepareStatement(
    "SELECT r.id, r.rating, r.review_text, r.created_at, m.username " +
    "FROM grocery_review r JOIN member m ON r.member_id=m.id " +
    "WHERE r.company_id=? ORDER BY r.created_at DESC"
);
reviewStmt.setInt(1, companyId);
ResultSet reviewRs = reviewStmt.executeQuery();
%>

<!DOCTYPE html>
<html>
<head>
<title>Grocery Details</title>
<link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">

<style>
    body { background:#f3f4f6; }
    .gradient-card {
        background: linear-gradient(135deg, #fff7e0, #ffedc2);
        border-left: 4px solid #fbbf24;
    }
    .review-card {
        background:white;
        border-radius:12px;
        border:1px solid #e5e7eb;
        padding:18px;
        box-shadow:0 1px 4px rgba(0,0,0,0.05);
    }
    .reply-card {
        background:#f9fafb;
        border-left:4px solid #93c5fd;
        border-radius:8px;
        padding:12px;
    }
    .item-card {
        background:white;
        padding:16px;
        border-radius:10px;
        border:1px solid #ddd;
        box-shadow:0 1px 3px rgba(0,0,0,0.05);
        transition:0.2s;
    }
    .item-card:hover {
        transform:scale(1.02);
    }
</style>
</head>

<body class="pb-20">
<jsp:include page="/home/NavBar.jsp" />

<div class="max-w-7xl mx-auto mt-6 px-6">

    <!-- PROVIDER DETAILS -->
    <h1 class="text-3xl font-bold mb-2"><%= provider.getString("name") %></h1>

    <p class="text-gray-600">
        ⭐ <span class="font-semibold"><%= String.format("%.1f", provider.getDouble("rating")) %></span> / 5  
    </p>

    <p class="mt-2">
        <span class="font-semibold">Delivery Fee:</span> $<%= shippingFee %><br>
        <span class="font-semibold">Estimated Time:</span> <%= provider.getString("est_delivery_time") %><br>
        <span class="font-semibold">Location:</span> <%= provider.getString("location") %>
    </p>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mt-8">

        <!-- LEFT SIDE — ITEMS + ORDER -->
        <div>

            <h2 class="text-xl font-bold mb-4">Available Grocery Items</h2>

            <form action="GroceryBooking.jsp" method="post" id="orderForm">
                <input type="hidden" name="company_id" value="<%= companyId %>">
                <input type="hidden" id="order_total" name="order_total">
                <input type="hidden" id="shipping_fee" name="shipping_fee" value="<%= shippingFee %>">

            <% boolean hasItems=false; 
               while(itemRs.next()){ 
               hasItems=true; %>

                <div class="item-card mb-4">
                    <p class="text-lg font-semibold"><%= itemRs.getString("name") %></p>
                    <p class="text-gray-500 text-sm"><%= itemRs.getString("description") %></p>

                    <p class="mt-2 font-semibold text-green-700">
                        $<%= itemRs.getDouble("price") %>
                    </p>

                    <div class="mt-3">
                        <label class="font-semibold">Quantity:</label>
                        <input type="number" min="0" value="0"
                               class="qtyBox border rounded p-1 w-20 ml-2"
                               data-price="<%= itemRs.getDouble("price") %>"
                               name="item_<%= itemRs.getInt("id") %>">
                    </div>
                </div>

            <% } if(!hasItems){ %>
                <p>No items available.</p>
            <% } %>

                <!-- DISCOUNTS -->
                <h2 class="text-xl font-bold mt-8">Available Discounts</h2>

                <% if(discountList.size()==0){ %>
                    <p class="text-gray-500">No discounts available.</p>
                <% } else {
                    for(Discount d : discountList){ %>

                    <div class="gradient-card p-4 mt-3 rounded-lg shadow-sm">
                        <p class="font-bold text-yellow-700 text-lg"><%= d.name %></p>

                        <% if("PERCENT".equalsIgnoreCase(d.type)){ %>
                            <p class="text-sm"> <%= d.amount %>% off</p>
                        <% } else if("FLAT".equalsIgnoreCase(d.type)){ %>
                            <p class="text-sm"> $<%= d.amount %> off</p>
                        <% } else { %>
                            <p class="text-sm"> Shipping -$<%= d.amount %></p>
                        <% } %>

                        <p class="text-sm mt-1">Min Order: $<%= d.minOrder %></p>
                        <p class="text-sm">Stackable: <%= d.stack ? "Yes" : "No" %></p>

                        <p id="disc_<%= d.id %>" class="text-yellow-800 mt-1 text-sm">
                            Spend more to qualify.
                        </p>
                    </div>

                <% }} %>
<!-- ===================== ORDER SUMMARY (ADDED) ===================== -->
<h2 class="text-xl font-bold mt-8">Order Summary</h2>

<div class="summary-card mt-3 bg-white border rounded-lg shadow p-5">

    <div class="flex justify-between mb-2">
        <span>Subtotal:</span>
        <span class="font-semibold">$<span id="subtotal">0.00</span></span>
    </div>

    <div class="flex justify-between mb-2">
        <span>Discounts Applied:</span>
        <span class="font-semibold text-green-700">-$<span id="discountApplied">0.00</span></span>
    </div>

    <div class="flex justify-between mb-2">
        <span>Shipping Fee:</span>
        <span class="font-semibold">$<span id="shippingRow"><%= String.format("%.2f", shippingFee) %></span></span>
    </div>

    <hr class="my-3">

    <div class="flex justify-between text-xl font-bold">
        <span>Total:</span>
        <span>$<span id="finalTotal">0.00</span></span>
    </div>

</div>
<!-- ================= END ORDER SUMMARY ================= -->

                <!-- DELIVERY DATE -->
                <h2 class="text-xl font-bold mt-8">Select Delivery Date</h2>

                <input type="date" name="booking_date" required
                       class="border p-2 rounded w-48 mt-2">

                <button class="w-full bg-blue-600 text-white p-3 rounded-lg mt-6 hover:bg-blue-700 transition">
                    Proceed to Booking
                </button>

            </form>
        </div>


<!-- RIGHT SIDE — REVIEWS -->
<div>

    <h2 class="text-xl font-bold mb-4">Customer Reviews</h2>

    <%
        Integer sessionMemberId = (Integer) session.getAttribute("member_id");
        boolean canReview = false;

        if (sessionMemberId != null) {
            PreparedStatement chk = conn.prepareStatement(
                "SELECT COUNT(*) FROM grocery_order WHERE member_id=? AND company_id=? AND status='COMPLETED'"
            );
            chk.setInt(1, sessionMemberId);
            chk.setInt(2, companyId);
            ResultSet rr = chk.executeQuery();
            rr.next();
            canReview = rr.getInt(1) > 0;
        }
    %>

    <% if (sessionMemberId != null && canReview) { %>
        <div class="review-card mb-6 bg-white p-5 rounded-xl shadow">
            <h3 class="font-bold text-lg mb-3">Write a Review</h3>

            <form action="SubmitGroceryReview.jsp" method="post">
                <input type="hidden" name="company_id" value="<%= companyId %>">

                <label class="font-semibold">Rating</label>
                <select name="rating" class="border p-2 rounded w-full mt-1 mb-3" required>
                    <option value="">Select rating</option>
                    <option value="1">1 ★</option>
                    <option value="2">2 ★</option>
                    <option value="3">3 ★</option>
                    <option value="4">4 ★</option>
                    <option value="5">5 ★</option>
                </select>

                <label class="font-semibold">Review</label>
                <textarea name="review_text" rows="3" class="border p-2 rounded w-full mt-1" required></textarea>

                <button class="w-full bg-green-600 text-white rounded p-2 mt-4 hover:bg-green-700">
                    Submit Review
                </button>
            </form>
        </div>
    <% } %>

    <%
        PreparedStatement getReviews = conn.prepareStatement(
            "SELECT r.id,r.rating,r.review_text,r.created_at,r.member_id,m.username " +
            "FROM grocery_review r JOIN member m ON r.member_id=m.id " +
            "WHERE r.company_id=? ORDER BY r.created_at DESC"
        );
        getReviews.setInt(1, companyId);
        ResultSet reviewRs2 = getReviews.executeQuery();

        boolean hasReviews = false;
        while (reviewRs2.next()) {
            hasReviews = true;
            int reviewId = reviewRs2.getInt("id");
            int reviewOwner = reviewRs2.getInt("member_id");
    %>

    <!-- REVIEW CARD -->
    <div class="review-card mt-6 p-5 border rounded-xl bg-white shadow">

        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-blue-200 text-blue-700 rounded-full flex items-center justify-center font-bold text-lg">
                <%= reviewRs2.getString("username").charAt(0) %>
            </div>

            <div>
                <p class="font-semibold"><%= reviewRs2.getString("username") %></p>
                <p class="text-sm text-gray-500"><%= reviewRs2.getTimestamp("created_at") %></p>
            </div>

            <span class="ml-auto bg-yellow-300 text-yellow-900 font-bold px-3 py-1 rounded-full">
                <%= reviewRs2.getInt("rating") %> ★
            </span>
        </div>

        <!-- Static review text -->
        <p id="reviewText_<%=reviewId%>" class="mt-3 text-gray-700 block">
            <%= reviewRs2.getString("review_text") %>
        </p>

        <!-- INLINE EDIT REVIEW FORM (hidden initially) -->
        <form id="editReviewForm_<%=reviewId%>" 
              action="SubmitGroceryReview.jsp" 
              method="post" 
              class="hidden mt-3">

            <input type="hidden" name="review_id" value="<%= reviewId %>">
            <input type="hidden" name="company_id" value="<%= companyId %>">

            <select name="rating" class="border p-2 rounded mb-2 w-32">
                <option value="1" <%= reviewRs2.getInt("rating")==1?"selected":"" %>>1 ★</option>
                <option value="2" <%= reviewRs2.getInt("rating")==2?"selected":"" %>>2 ★</option>
                <option value="3" <%= reviewRs2.getInt("rating")==3?"selected":"" %>>3 ★</option>
                <option value="4" <%= reviewRs2.getInt("rating")==4?"selected":"" %>>4 ★</option>
                <option value="5" <%= reviewRs2.getInt("rating")==5?"selected":"" %>>5 ★</option>
            </select>

            <textarea name="review_text" rows="3" class="border p-2 rounded w-full mb-2">
                <%= reviewRs2.getString("review_text") %>
            </textarea>

            <button class="px-3 py-1 bg-blue-600 text-white rounded text-sm">Save</button>
            <button type="button" 
                    class="px-3 py-1 bg-gray-400 text-white rounded text-sm"
                    onclick="cancelReviewEdit(<%=reviewId%>)">
                Cancel
            </button>

        </form>

        <% if (sessionMemberId != null && sessionMemberId == reviewOwner) { %>
        <div class="flex gap-3 mt-4">
            <button onclick="editReview(<%=reviewId%>)"
                class="px-3 py-1 bg-blue-500 text-white rounded hover:bg-blue-600 text-sm">
                Edit
            </button>

            <a href="DeleteGroceryReview.jsp?id=<%= reviewId %>"
   onclick="return confirm('Delete this review?');"
   class="px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700 text-sm">
   Delete
</a>

        </div>
        <% } %>

        <!-- REPLIES -->
        <%
            PreparedStatement r2 = conn.prepareStatement(
                "SELECT rr.id,rr.reply_text,rr.created_at,rr.member_id,m.username " +
                "FROM grocery_review_reply rr JOIN member m ON rr.member_id=m.id " +
                "WHERE rr.review_id=? ORDER BY rr.created_at"
            );
            r2.setInt(1, reviewId);
            ResultSet replyRs2 = r2.executeQuery();
        %>

        <% while (replyRs2.next()) {
            int replyId = replyRs2.getInt("id");
            int replyOwner = replyRs2.getInt("member_id");
        %>

        <!-- Reply card -->
        <div class="reply-card mt-3 ml-6 p-3 bg-gray-100 rounded border-l-4 border-blue-400">

            <p class="font-bold text-blue-700"><%= replyRs2.getString("username") %></p>
            <p class="text-xs text-gray-500"><%= replyRs2.getTimestamp("created_at") %></p>

            <!-- Static reply text -->
            <p id="replyText_<%=replyId%>" class="mt-1">
                <%= replyRs2.getString("reply_text") %>
            </p>

            <!-- Inline edit reply form -->
            <form id="editReplyForm_<%=replyId%>"
                  action="SubmitGroceryReplyUpdate.jsp"
                  method="post"
                  class="hidden mt-2">

                <input type="hidden" name="reply_id" value="<%=replyId%>">
                <input type="hidden" name="review_id" value="<%=reviewId%>">

                <textarea name="reply_text" rows="2" class="border p-2 rounded w-full mb-2">
                    <%= replyRs2.getString("reply_text") %>
                </textarea>

                <button class="px-2 py-1 bg-blue-600 text-white rounded text-sm">Save</button>
                <button type="button"
                        onclick="cancelReplyEdit(<%=replyId%>)"
                        class="px-2 py-1 bg-gray-400 text-white rounded text-sm">
                    Cancel
                </button>
            </form>

            <% if (sessionMemberId != null && sessionMemberId == replyOwner) { %>
            <div class="flex gap-2 mt-2">
                <button onclick="editReply(<%=replyId%>)"
                    class="px-2 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600">
                    Edit
                </button>

                <a href="DeleteGroceryReply.jsp?reply_id=<%=replyId%>&review_id=<%=reviewId%>&company_id=<%=companyId%>"
                   onclick="return confirm('Delete this reply?');"
                   class="px-2 py-1 bg-red-600 text-white rounded text-sm hover:bg-red-700">
                    Delete
                </a>
            </div>
            <% } %>

        </div>

        <% } %> <!-- end replies -->

        <!-- ADD REPLY -->
        <% if (sessionMemberId != null) { %>
        <form action="SubmitGroceryReply.jsp" method="post" class="ml-6 mt-4">
            <input type="hidden" name="review_id" value="<%= reviewId %>">
            <textarea name="reply_text" rows="2" class="border p-2 rounded w-full" required></textarea>
            <button class="bg-gray-800 text-white px-3 py-1 rounded mt-2">Reply</button>
        </form>
        <% } %>

    </div>

    <% } if (!hasReviews) { %>
        <p class="text-gray-500">No reviews yet.</p>
    <% } %>

</div>
</div>
</div>
<script>
let shippingFee = parseFloat("<%= shippingFee %>");

document.querySelectorAll('.qtyBox').forEach(box => {
    box.addEventListener('input', updateTotals);
});
function editReview(id){
    document.getElementById("reviewText_"+id).style.display="none";
    document.getElementById("editReviewForm_"+id).classList.remove("hidden");
}
function cancelReviewEdit(id){
    document.getElementById("reviewText_"+id).style.display="block";
    document.getElementById("editReviewForm_"+id).classList.add("hidden");
}
function editReply(id){
    document.getElementById("replyText_"+id).style.display="none";
    document.getElementById("editReplyForm_"+id).classList.remove("hidden");
}
function cancelReplyEdit(id){
    document.getElementById("replyText_"+id).style.display="block";
    document.getElementById("editReplyForm_"+id).classList.add("hidden");
}

function updateTotals() {
    let subtotal = 0;

    document.querySelectorAll('.qtyBox').forEach(box => {
        let qty = parseInt(box.value);
        let price = parseFloat(box.getAttribute('data-price'));

        if (!isNaN(qty) && qty > 0) {
            subtotal += qty * price;
        }
    });

    document.getElementById("subtotal").innerText = subtotal.toFixed(2);

    let discountAmount = calculateDiscounts(subtotal);
    document.getElementById("discountApplied").innerText = discountAmount.toFixed(2);

    let shipping = applyShippingDiscount(subtotal);
    document.getElementById("shippingRow").innerText = shipping.toFixed(2);

    let finalTotal = subtotal + shipping - discountAmount;
    document.getElementById("finalTotal").innerText = finalTotal.toFixed(2);

    document.getElementById("order_total").value = finalTotal.toFixed(2);

    updateDiscountLabels(subtotal);
}

function calculateDiscounts(subtotal) {
    let bestFlatOrPercent = 0; 
    let stackableDiscounts = 0;
    let nonStackApplied = false;
    let shippingDiscount = 0;

<%
for (Discount d : discountList) {
%>
    if (subtotal >= <%= d.minOrder %>) {

        <% if ("PERCENT".equalsIgnoreCase(d.type)) { %>
            let amount = subtotal * (<%= d.amount %> / 100);
            <% if (d.stack) { %> stackableDiscounts += amount; <% } else { %> bestFlatOrPercent = Math.max(bestFlatOrPercent, amount); <% } %>

        <% } else if ("FLAT".equalsIgnoreCase(d.type)) { %>
            let amount = <%= d.amount %>;
            <% if (d.stack) { %> stackableDiscounts += amount; <% } else { %> bestFlatOrPercent = Math.max(bestFlatOrPercent, amount); <% } %>

        <% } else if ("SHIPPING".equalsIgnoreCase(d.type)) { %>
            shippingDiscount = Math.max(shippingDiscount, <%= d.amount %>);
        <% } %>
    }
<% } %>

    // shipping discount handled separately
    return stackableDiscounts + bestFlatOrPercent;
}

function applyShippingDiscount(subtotal) {
    let finalShipping = shippingFee;

<%
for (Discount d : discountList) {
    if ("SHIPPING".equalsIgnoreCase(d.type)) {
%>
    if (subtotal >= <%= d.minOrder %>) {
        finalShipping = Math.max(0, shippingFee - <%= d.amount %>);
    }
<%
    }
}
%>

    return finalShipping;
}

function updateDiscountLabels(subtotal) {
<%
for (Discount d : discountList) {
%>
    if (subtotal >= <%= d.minOrder %>) {
        document.getElementById("disc_<%= d.id %>").innerHTML =
            "<strong style='color:green;'>You qualify for this discount!</strong>";
    } else {
        let need = (<%= d.minOrder %> - subtotal).toFixed(2);
        document.getElementById("disc_<%= d.id %>").innerHTML =
            "Spend <strong>$" + need + "</strong> more to qualify.";
    }
<%
}
%>
}
</script>

</body>
</html>

<%
conn.close();
%>
