<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<jsp:include page="/auth/AuthCheck.jsp" />

<%
/* ===============================
   1. SETUP & DB CONNECTION
================================*/
Class.forName("com.mysql.cj.jdbc.Driver");
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";
Connection conn = DriverManager.getConnection(connURL);

String username = (String) session.getAttribute("username");
if (username == null) username = "Guest";

String ctx = request.getContextPath();
String profilePic = ctx + "/Services/Cleaning/Images/profile.jpg";

/* ===============================
   2. GET USER PROFILE PIC
================================*/
PreparedStatement psUser = conn.prepareStatement(
	    "SELECT id, profile_pic FROM member WHERE username = ?"
	);
	psUser.setString(1, username);
	ResultSet rsUser = psUser.executeQuery();

	int memberId = -1;

	if (rsUser.next()) {
	    memberId = rsUser.getInt("id");   // 💥 SET memberId properly
	    String pp = rsUser.getString("profile_pic");
	    if (pp != null && !pp.isEmpty()) {
	        profilePic = ctx + "/Services/Cleaning/Images/" + pp;
	    }
	}

	rsUser.close();
	psUser.close();


/* ===============================
   3. READ FILTERS FROM REQUEST
================================*/
int cleaningTypeId = 1; // default = Housekeeping
String[] selectedLangs = request.getParameterValues("lang");
String priceOrder = request.getParameter("priceOrder");

/* ===============================
   4. BUILD CLEANER QUERY DYNAMICALLY
================================*/
StringBuilder sql = new StringBuilder(
 "SELECT c.id, c.name, c.profile_url, c.base_hourly_pay, c.race, c.language, " +
 "       c.max_booking_per_day, (c.base_hourly_pay + ct.pay_increment) AS hourly_rate " +
 "FROM cleaner c " +
 "JOIN cleaner_cleaning_type cct ON c.id = cct.cleaner_id " +
 "JOIN cleaning_type ct ON ct.id = cct.cleaning_type_id " +
 "WHERE ct.id = ? "
);

// Language filter
if (selectedLangs != null && selectedLangs.length > 0) {
    sql.append(" AND (");
    for (int i = 0; i < selectedLangs.length; i++) {
        if (i > 0) sql.append(" OR ");
        sql.append(" c.language LIKE ? ");
    }
    sql.append(")");
}

// Price order
if (priceOrder != null) {
    sql.append(" ORDER BY hourly_rate ASC");
}

/* ===============================
   5. PREPARE CLEANER QUERY
================================*/
PreparedStatement psCleaners = conn.prepareStatement(sql.toString());

int paramIndex = 1;
psCleaners.setInt(paramIndex++, cleaningTypeId);

if (selectedLangs != null && selectedLangs.length > 0) {
    for (String lang : selectedLangs) {
        psCleaners.setString(paramIndex++, "%" + lang + "%");
    }
}

ResultSet rsCleaners = psCleaners.executeQuery();

/* ===============================
   6. SERVICE QUERY (IF YOU USE IT)
================================*/
PreparedStatement psSvc = conn.prepareStatement(
    "SELECT name, service_link FROM service WHERE category_id = ?"
);

int cleaningCategoryId = 2; 
psSvc.setInt(1, cleaningCategoryId);
ResultSet rsSvc = psSvc.executeQuery();

/* ===============================
7. LEAVING A REVIEW
================================*/
PreparedStatement psReview = conn.prepareStatement(
    "SELECT DISTINCT c.id, c.name " +
    "FROM cleaner_booking b " +
    "JOIN cleaner c ON b.cleaner_id = c.id " +
    "WHERE b.member_id = ? " +
    "AND b.cleaning_type_id = ? " +
    "AND b.status = 'paid'"
);
psReview.setInt(1, memberId);   // use the REAL memberId retrieved earlier
psReview.setInt(2, cleaningTypeId);
ResultSet rsEligible = psReview.executeQuery();

/* ===============================
	8. GET REVIEWS
================================*/
			PreparedStatement psReviews = conn.prepareStatement(
				    "SELECT r.id, r.member_id, r.review_text, r.created_at, " +
				    "       m.username, c.name " +
				    "FROM cleaning_review r " +
				    "JOIN member m ON r.member_id = m.id " +
				    "JOIN cleaner c ON r.cleaner_id = c.id " +
				    "WHERE r.cleaning_type_id = ? " +
				    "ORDER BY r.created_at DESC"
				);
				psReviews.setInt(1, cleaningTypeId);
				ResultSet rsReviews = psReviews.executeQuery();



%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>House Keeping</title>
<link rel="stylesheet" href="<%= ctx %>/Services/Cleaning/cleaning.css">

</head>

<body>
<jsp:include page="/home/NavBar.jsp"/>

<section class="profile">
  <img class="avatar" src="<%= profilePic %>" />
  <span class="name"><%= username %></span>
</section>

<div class="page-wrap">
  <!-- LEFT FILTER PANEL -->
  <aside class="filters">
<form method="get" action="<%= ctx %>/Services/Cleaning/SpringCleaning.jsp">
      <h3>Price Range (S$ per hour)</h3>
      <label class="checkbox-row">
        <input type="checkbox" name="priceOrder" value="asc" />
        lowest to highest
      </label>

      <h3>Language</h3>
      <label class="checkbox-row">
        <input type="checkbox" name="lang" value="English" /> English
      </label>
      <label class="checkbox-row">
        <input type="checkbox" name="lang" value="Chinese" /> Chinese
      </label>
      <label class="checkbox-row">
        <input type="checkbox" name="lang" value="Bahasa" /> Bahasa Indonesia/Malaysia
      </label>
      <label class="checkbox-row">
        <input type="checkbox" name="lang" value="Tamil" /> Tamil
      </label>
      
      <button type="submit" class="apply-btn">
        apply
      </button>
      <button type="button" class="reset-btn" onclick="resetFilters()">
        reset
      </button>
      </form>

  <!-- to redirect to other cleaning pages -->
    <div class="cleaning-type-buttons">
  <%
    String currentPath = request.getRequestURI().substring(request.getContextPath().length());

    while (rsSvc.next()) {
        String svcName = rsSvc.getString("name");
        String svcLink = rsSvc.getString("service_link"); 
        // e.g. store in DB as "/Services/Cleaning/HouseKeeping.jsp"

        String activeClass = currentPath.equals(svcLink) ? " active" : "";
  %>
        <a href="<%= ctx + svcLink %>" class="type-btn<%= activeClass %>">
          <%= svcName %>
        </a>
  <%
    }
  %>
</div>
  
  
  </aside>

  <!-- RIGHT CONTENT: CLEANER CARDS -->
  <main class="cleaner-section">
<h2 class="page-title">Housekeeping</h2>
<p class="subtitle">Regular weekly cleaning & tidying services.</p>

    <div class="badges-row">
      <span>✅ cancel anytime</span>
      <span>✅ Legal workers</span>
      <span>✅ friendly workers</span>
      <span>✅ instant booking</span>
    </div>
<form method="get" action="<%= ctx %>/Services/Cleaning/bookCleaner.jsp">
    <input type="hidden" name="cleaningTypeId" value="<%= cleaningTypeId %>">

    <div class="cleaner-cards">
       <%
while (rsCleaners.next()) {
    int cleanerId = rsCleaners.getInt("id");
    String name = rsCleaners.getString("name");
    String race = rsCleaners.getString("race");
    String language = rsCleaners.getString("language");
    double hourly = rsCleaners.getDouble("hourly_rate");
    int maxHours = rsCleaners.getInt("max_booking_per_day");
    String photo = rsCleaners.getString("profile_url");

    String photoSrc = ctx + "/Services/Cleaning/Images/" + photo;
%>

<div class="cleaner-card">

    <img class="cleaner-photo"
         src="<%= photoSrc %>"
         onerror="this.src='<%= ctx %>/Services/Cleaning/Images/profile.jpg'">

    <div class="cleaner-info">
        <p class="cleaner-name"><%= name %> (<%= race %>)</p>
        <p>$<%= hourly %> per hour</p>
        <p><%= language %></p>
    </div>

    <button 
        type="submit" 
        name="cleanerId" 
        value="<%= cleanerId %>" 
        class="book-cleaner-btn">
        book
    </button>

</div>

<% } %>

    </div>
</form>

 <!-- LEAVING THE REVIEW -->

<h3>Leave a Review</h3>

<form method="post" action="<%= ctx %>/Services/Cleaning/submitReview.jsp" class="review-form">

    <!-- proper cleaning type -->
    <input type="hidden" name="cleaningTypeId" value="<%= cleaningTypeId %>">

    <label>Select cleaner you booked:</label>
    <select name="cleanerId" required class="review-select">
        <% 
        if (!rsEligible.isBeforeFirst()) { 
        %>
            <option disabled>No cleaners booked yet</option>
        <% 
        } else { 
            while (rsEligible.next()) { 
        %>
                <option value="<%= rsEligible.getInt("id") %>">
                    <%= rsEligible.getString("name") %>
                </option>
        <% 
            } 
        } 
        %>
    </select>

    <br>

    <textarea 
        name="review_text" 
        class="review-textarea"
        placeholder="Write your review..." 
        required>
    </textarea>

    <br>

    <button type="submit" class="review-submit-btn">Submit Review</button>

</form>

<!-- SHOWING REVIEWS -->
<h3>Reviews</h3>

<div class="reviews-list">
<%
boolean hasReviews = false;

while (rsReviews.next()) {
    hasReviews = true;

    int reviewId       = rsReviews.getInt("id");
    int reviewMemberId = rsReviews.getInt("member_id");
    String reviewer    = rsReviews.getString("username");
    String cleanerName = rsReviews.getString("name");
    String reviewText  = rsReviews.getString("review_text");
%>

  <div class="review-card">
    <p>
      <strong><%= reviewer %></strong>
      reviewed <em><%= cleanerName %></em>
    </p>
    <p><%= reviewText %></p>

    <% if (reviewMemberId == memberId) { %>
      <!-- Only show delete button for OWN reviews -->
      <form method="post"
            action="<%= ctx %>/Services/Cleaning/deleteReview.jsp"
            onsubmit="return confirm('Delete this review?');">
        <input type="hidden" name="reviewId" value="<%= reviewId %>">
        <input type="hidden" name="cleaningTypeId" value="<%= cleaningTypeId %>">
        <button type="submit" class="review-delete-btn">
          Delete my review
        </button>
      </form>
    <% } %>
  </div>

<%
} // end while

if (!hasReviews) {
%>
  <p>No reviews yet for this service.</p>
<%
}
%>
</div>



  </main>
 <%
rsCleaners.close();
psCleaners.close();
psSvc.close();
psReview.close();
psReviews.close();
conn.close();
%>
</div>

<script>
function resetFilters() {
    // reload the page WITHOUT any filters
    window.location.href = "<%= ctx %>/Services/Cleaning/SpringCleaning.jsp";
}
</script>
</body>

</html>