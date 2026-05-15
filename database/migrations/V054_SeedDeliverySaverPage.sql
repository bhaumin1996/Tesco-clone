-- V054_SeedDeliverySaverPage.sql
-- Author: Antigravity
-- Date: 2026-05-15
-- Description: Seed Delivery Saver page content with 12-month data placeholders
-- Dependencies: V011

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Delete existing if exists to update
    DELETE FROM t.tblPage WHERE Slug = 'delivery-saver';

    INSERT INTO t.tblPage (Title, Slug, Content, IsPublished, CreatedBy)
    VALUES (
        'Delivery Saver', 
        'delivery-saver', 
        '<div class="delivery-saver-page">
  <div class="hero-banner">
    <div class="banner-content">
      <h1>Save £176 on delivery and collection charges*</h1>
      <p>Get a weekly shop delivered? Or prefer Click+Collect? Sign up to Delivery Saver from £2.49 a month and you won’t have to pay for your slot.</p>
      <div class="info-badge">Priority Christmas slots included with Anytime plan</div>
    </div>
    <div class="banner-image">
      <img src="https://digitalcontent.api.tesco.com/v2/media/ghs-mktg/5d93e872-187a-4892-944b-a72451c35431/Delivery-Saver4.png" alt="Delivery Saver Banner">
    </div>
  </div>

  <section class="plan-selection">
    <h2>Choose a plan that suits the way you shop</h2>
    
    <div class="plan-tabs">
      <div class="tab-header">
        <button class="tab-btn active">6-month plans</button>
        <button class="tab-btn">12-month plans</button>
      </div>

      <div class="plan-grid">
        <!-- Anytime Plan -->
        <div class="plan-card featured" data-base-price="7.99">
          <div class="promo-tag">Most popular</div>
          <div class="plan-info">
            <h3>Anytime</h3>
            <div class="price-container">
              <div class="price">
                <span class="amount">£7.99</span>
                <span class="freq">a month for 6 months</span>
                <span class="original-price" style="display:none"></span>
              </div>
            </div>
            <p class="total">£47.94 in total</p>
            <p class="savings-text" style="display:none"></p>
            <p class="tagline">Your shopping, how you want it, when you want it</p>
            <a href="/auth/register" class="cta-btn">Sign up</a>
          </div>
          <div class="benefits">
            <h4>What’s included</h4>
            <ul>
              <li>Includes same-day delivery*</li>
              <li>Home Delivery for any available slot</li>
              <li>Early access to Christmas and Easter slots</li>
              <li>With our Delivery Saver guarantee, we’ll give you coupons for the difference if you don’t save on delivery charges</li>
              <li>Collection for any available slot</li>
            </ul>
            <p class="disclaimer">* Doesn''t include Whoosh and F&F Clothing</p>
          </div>
        </div>

        <!-- Off Peak Plan -->
        <div class="plan-card" data-base-price="4.99">
          <div class="plan-info">
            <h3>Off Peak</h3>
            <div class="price-container">
              <div class="price">
                <span class="amount">£4.99</span>
                <span class="freq">a month for 6 months</span>
                <span class="original-price" style="display:none"></span>
              </div>
            </div>
            <p class="total">£29.94 in total</p>
            <p class="savings-text" style="display:none"></p>
            <p class="tagline">Take advantage of our less busy delivery slots</p>
            <a href="/auth/register" class="cta-btn">Sign up</a>
          </div>
          <div class="benefits">
            <h4>What’s included</h4>
            <ul>
              <li>Home Delivery for any available slot after 3pm</li>
              <li>With our Delivery Saver guarantee, we’ll give you coupons for the difference if you don’t save on delivery charges</li>
              <li>Collection for any available slot</li>
            </ul>
          </div>
        </div>

        <!-- Click+Collect Plan -->
        <div class="plan-card" data-base-price="2.49">
          <div class="plan-info">
            <h3>Click+Collect</h3>
            <div class="price-container">
              <div class="price">
                <span class="amount">£2.49</span>
                <span class="freq">a month for 6 months</span>
                <span class="original-price" style="display:none"></span>
              </div>
            </div>
            <p class="total">£14.94 in total</p>
            <p class="savings-text" style="display:none"></p>
            <p class="tagline">Your shopping, picked, packed and ready to collect</p>
            <a href="/auth/register" class="cta-btn">Sign up</a>
          </div>
          <div class="benefits">
            <h4>What’s included</h4>
            <ul>
              <li>Includes same-day collection</li>
              <li>Collection for any available slot</li>
              <li>Early access to Christmas and Easter collection slots</li>
              <li>With our Delivery Saver guarantee, we’ll give you coupons for the difference if you don’t save on delivery charges</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </section>

  <section class="benefits-grid">
    <h2>Enjoy these Delivery Saver benefits</h2>
    <div class="grid">
      <div class="benefit-item">
        <div class="icon-container">
          <img src="https://digitalcontent.api.tesco.com/v2/media/ghs-mktg/c595c3c8-b5b1-4061-9227-8ea6a70221f5/Delivery-Saver3.png" alt="Same-day deliveries">
        </div>
        <h3>Same-day deliveries</h3>
        <p>Last-minute shop? On our Anytime plan, choose from available same-day slots.</p>
      </div>
      <div class="benefit-item">
        <div class="icon-container">
          <img src="https://digitalcontent.api.tesco.com/v2/media/ghs-mktg/d353a373-2d6e-486f-9293-80e4c1dd6ae5/Delivery-Saver5.png" alt="Access to more slots">
        </div>
        <h3>Access to more slots</h3>
        <p>Book up to 4 weeks in advance and get priority Christmas slots on our Anytime plan.</p>
      </div>
      <div class="benefit-item">
        <div class="icon-container">
          <img src="https://digitalcontent.api.tesco.com/v2/media/ghs-mktg/1b4bee9f-86dc-4674-9056-4109153622ad/Delivery-Saver2.png" alt="Never out of pocket">
        </div>
        <h3>Never out of pocket</h3>
        <p>With our Delivery Saver guarantee, if you don’t save on delivery and collection charges, we''ll give you a coupon for the difference.</p>
      </div>
      <div class="benefit-item">
        <div class="icon-container">
          <img src="https://digitalcontent.api.tesco.com/v2/media/ghs-mktg/ee849da4-bc5b-4d5f-a4cb-dbebcb50cb21/Delivery-Saver-4col-PPE.jpeg" alt="Collect when you like">
        </div>
        <h3>Collect when you like</h3>
        <p>All of our plans include same-day Click+Collect, which you can pick up any time the store is open.</p>
      </div>
    </div>
  </section>

  <section class="footer-info">
    <p>See the full Delivery Saver <a href="/delivery-saver/terms" class="tc-link">terms and conditions</a></p>
    <h2>Still have questions?</h2>
    <p>We’re trialling the WhatsApp messaging service to answer questions about your Delivery Saver account or our plans.</p>
    <div class="contact-options">
      <a href="https://wa.me/448009177403" target="_blank" class="contact-card">
        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M12.031 6.172c-2.203 0-4.007 1.797-4.007 3.992 0 .586.125 1.156.367 1.68l-.398 1.469 1.508-.391c.516.289 1.109.438 1.719.438 2.203 0 4.008-1.797 4.008-3.992 0-2.203-1.805-3.992-4.008-3.992zm2.148 5.75c-.094.266-.461.508-.75.586-.289.07-.648.117-1.047-.008-.258-.078-1.047-.398-1.992-1.242-.727-.648-1.219-1.445-1.359-1.688-.148-.25-.016-.383.109-.508.117-.109.266-.289.398-.43.133-.148.18-.25.266-.422.094-.172.047-.328-.023-.469-.07-.148-.641-1.547-.875-2.117-.234-.562-.469-.484-.641-.492h-.547c-.188 0-.5-.07-.766.211-.266.289-1.016.992-1.016 2.422 0 1.43 1.047 2.813 1.188 3 1.188.188 2.055 3.125 4.969 4.383.695.297 1.234.477 1.656.609.695.219 1.328.188 1.828.117.562-.086 1.727-.703 1.969-1.383.25-.68.25-1.266.172-1.383-.07-.117-.266-.188-.562-.336zM12 0C5.375 0 0 5.375 0 12c0 2.125.547 4.125 1.516 5.859L0 24l6.328-1.656C7.938 23.422 9.906 24 12 24c6.625 0 12-5.375 12-12S18.625 0 12 0zM12 21.984c-1.922 0-3.805-.516-5.461-1.484l-.391-.234-3.75.984.992-3.664-.258-.406c-1.07-1.688-1.633-3.648-1.633-5.688 0-5.508 4.484-9.992 9.992-9.992s9.992 4.484 9.992 9.992-4.484 9.992-9.992 9.992z"/></svg>
        WhatsApp Us
      </a>
      <a href="sms:08009177403" class="contact-card">
        <svg viewBox="0 0 24 24" fill="currentColor"><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z"/></svg>
        SMS: 0800 917 7403
      </a>
    </div>
  </section>
</div>', 
        1, 
        1
    );
    PRINT 'Delivery Saver page seeded with internal terms link.';

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V054')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V054', 'SeedDeliverySaverPage');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
