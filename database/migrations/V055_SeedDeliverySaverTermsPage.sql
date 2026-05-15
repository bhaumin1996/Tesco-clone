-- V055_SeedDeliverySaverTermsPage.sql
-- Author: Antigravity
-- Date: 2026-05-15
-- Description: Seed Delivery Saver Terms & Conditions page content
-- Dependencies: V011

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM t.tblPage WHERE Slug = 'delivery-saver-terms')
    BEGIN
        INSERT INTO t.tblPage (Title, Slug, Content, IsPublished, CreatedBy)
        VALUES (
            'Delivery Saver Terms & Conditions', 
            'delivery-saver-terms', 
            '<div class="terms-page">
  <div class="terms-header">
    <h1>Tesco Delivery Saver Terms & Conditions</h1>
    <p class="intro">Please read these terms and conditions carefully as they affect your rights and liabilities under the law and set out the terms under which Tesco makes the Membership of Delivery Saver available to you.</p>
  </div>

  <div class="terms-body">
    <section class="general-info">
      <div class="info-card">
        <p>Please note that our <a href="/terms-and-conditions">General Terms and Conditions</a> and our <a href="/product-terms">Product Terms and Conditions</a> also apply to your Membership of Delivery Saver.</p>
      </div>
      <div class="info-card warning">
        <p><strong>Note:</strong> Your Membership will automatically renew at the end of each Membership Period unless you provide us with notice to terminate.</p>
      </div>
    </section>

    <section class="definitions">
      <h2>In these terms and conditions</h2>
      <div class="definition-grid">
        <div class="def-item"><strong>Contract Period:</strong> The length of Membership selected by you when you sign up or renew.</div>
        <div class="def-item"><strong>Delivery Saver:</strong> Our subscription based service for the delivery of Products.</div>
        <div class="def-item"><strong>Membership:</strong> Your subscription for Delivery Saver.</div>
        <div class="def-item"><strong>Membership Fee:</strong> The payment due for Membership during your Membership Period.</div>
        <div class="def-item"><strong>Membership Period:</strong> The length of Membership selected by you including each automatic renewal.</div>
        <div class="def-item"><strong>Products:</strong> Tesco groceries.</div>
        <div class="def-item"><strong>Qualifying Order:</strong> An order placed in accordance with your chosen plan.</div>
        <div class="def-item"><strong>Qualifying Website:</strong> https://www.tesco.com/groceries/</div>
        <div class="def-item"><strong>Same-Day:</strong> An order placed for delivery or collection on the same day.</div>
      </div>
    </section>

    <section class="accordions">
      <div class="accordion-item" id="plans">
        <button class="accordion-trigger">
          <span>Delivery Saver plans</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>You will be able to select from the plans and Contract Periods currently available on the Qualifying Website. The price of each plan will be as stated on the Qualifying Website.</p>
            <p>Delivery Saver applies to Qualifying Orders of Products (defined as Tesco groceries), as detailed in each plan. Marketplace Products are excluded from Delivery Saver plans.</p>
            
            <div class="sub-plan">
              <h3>1. Click+Collect plan</h3>
              <ul>
                <li>One collection per day at any time (including Same-Day) subject to availability of slots.</li>
                <li>The minimum value of each grocery order is £25.</li>
                <li>Priority access to Christmas and Easter slots for collection.</li>
              </ul>
            </div>

            <div class="sub-plan">
              <h3>2. Off Peak delivery plan</h3>
              <ul>
                <li>Delivery for slots booked from and after 3pm only.</li>
                <li>Collections any time of day (including Same-Day).</li>
                <li>One delivery or collection per day.</li>
                <li>The minimum value of each grocery order is £50.</li>
              </ul>
            </div>

            <div class="sub-plan">
              <h3>3. Anytime delivery plan</h3>
              <ul>
                <li>One delivery or collection per day at any time (including Same-Day).</li>
                <li>The minimum value of each grocery order is £50.</li>
                <li>Priority access to Christmas and Easter slots.</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Your contract</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>Your contract for Delivery Saver is with Tesco. Your contract is made when we successfully process payment of your Membership Fee. By signing for Membership, you confirm that you have read and understood all of our terms and conditions.</p>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Qualifying Orders</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>If you place an order which is not a Qualifying Order, you will be charged the same delivery fees as if you were not a Member. Delivery Saver is available for non-commercial and domestic use only.</p>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Delivery and collection slots</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>Membership allows you to choose any delivery or collection slot available on the days and times that the plan is valid. Membership does not guarantee any particular delivery slot.</p>
            <p>Same-Day deliveries or collections are subject to availability and unavailable during peak trading (19 Dec - 3 Jan) and bank holidays.</p>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Automatic renewal</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>At the end of each Contract Period, your Membership will automatically renew for the same period unless you notify us. You authorise us to take the Membership Fee using the payment details from your account.</p>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Cancellation and Membership Fee</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>You can cancel your Membership within 14 days of the commencement of the relevant Contract Period. If you cancel before receiving a delivery, we will provide a full refund.</p>
            <p>You can cancel your renewal via the My Plan page or by calling our Customer Service team on 0800 323 4040.</p>
          </div>
        </div>
      </div>

      <div class="accordion-item">
        <button class="accordion-trigger">
          <span>Delivery Saver Guarantee</span>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="m6 9 6 6 6-6"/></svg>
        </button>
        <div class="accordion-content">
          <div class="content-padding">
            <p>We guarantee that your Membership will cost you less than you would otherwise pay for individual deliveries. If you don''t save, we will refund the difference as a Tesco eCoupon.</p>
          </div>
        </div>
      </div>
    </section>
  </div>
</div>', 
            1, 
            1
        );
        PRINT 'Delivery Saver Terms page seeded.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V055')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V055', 'SeedDeliverySaverTermsPage');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
