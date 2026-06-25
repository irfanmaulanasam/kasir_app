# CHANGELOG

## v0.4.0-alpha

### Added

#### Supplier Debt

- Supplier debt management
- Add supplier debt manually
- Partial supplier debt payment
- Full supplier debt settlement
- Supplier debt detail page
- Supplier payment history
- Active / Paid supplier filter

#### Activity

- Supplier debt payments appear in activity timeline

#### Cash Flow

- Supplier debt payments reduce cash balance
- Supplier debt payments included in cash summary

### Improved

- Improved supplier debt workflow
- Automatic refresh after supplier debt settlement
- Better validation for supplier debt payment

### Fixed

- Fixed supplier list not refreshing after debt payment
- Fixed dialog controller lifecycle issues

---

## v0.3.1-alpha

### Internal

- Ignored build artifacts
- Cleaned unused generated files
- Removed unnecessary Kotlin compiler files

---

## v0.3.0-alpha

### Added

#### Activity

- Activity timeline
- Activity filter: Semua, Penjualan, Pengeluaran, Stok, Piutang
- Activity period filter: Hari Ini, 7 Hari, 30 Hari
- Activity cash summary
- Pull-to-refresh activity page
- Navigation from activity items to related detail pages

#### Piutang

- Customer debt management
- Customer detail page
- Customer debt summary
- Debt payment history
- Customer-based debt settlement workflow
- Tempo payment workflow
- Autocomplete customer name for tempo transaction

#### Expenses

- Expense management
- Expense detail page
- Activity integration for expenses

#### Inventory

- Stock log detail page
- Activity integration for stock movement
- Minimum stock management

#### Transactions

- Transaction detail page improvements
- Payment method validation
- Tempo payment scenario
- Transaction navigation from Activity page

#### Data Safety

- Backup database
- Restore database foundation

#### App Branding

- Application icon

### Improved

#### UX

- Replaced most SnackBar notifications with AppDialog
- Better navigation flow between modules
- Cleaner activity timeline layout
- Better readability for transaction and debt workflow
- Improved payment input visibility based on payment method
- Improved piutang page readability

#### Architecture

- ActivityPage refactored into modular widgets
- ActivitySummaryCard extracted
- ActivityItemCard extracted
- ActivityFilterBar extracted
- ActivityRangeBar extracted
- Shared InfoRow widget
- Currency formatting moved to global formatter

#### Database

- Reset development database to version 1
- Improved piutang database structure
- Added piutang payment table

### Fixed

- Fixed debt summary loading issue
- Fixed null customer references in debt records
- Fixed customer debt detail crash
- Fixed payment validation issues
- Fixed activity sorting consistency
- Fixed stock refresh after transaction
- Fixed stock returning to zero after insert
- Fixed filtered activity index issue

---

## v0.2.0-alpha

### Added

#### Inventory

- Stock history
- Minimum stock warning
- Inventory adjustment notes

#### Transaction

- Improved payment flow
- Optimized transaction cart
- Product search
- Transaction detail page
- Transaction history detail

#### Receipt

- Store settings for receipt printing
- Receipt preview improvements
- Basic printing functionality

#### Navigation

- Sidebar drawer menu
- Dashboard/menu restructuring

### Improved

#### Documentation

- Restructured README
- Added documentation links
- Added application state mapping documentation
- Added stability level section

#### Architecture

- Refactored transaction page into smaller widgets
- Split receipt preview page into widgets
- Moved reusable currency text field to core
- Added unit converter foundation

#### UX

- Improved inventory page readability
- Improved product maintenance page readability
- Changed labels and titles to Bahasa Indonesia

### Fixed

- Fixed database schema issues
- Fixed minor transaction page issues
- Fixed receipt preview issues
- Cleaned unused files and testing folders

---

## v0.1.0-alpha

### Added

#### Project Foundation

- Initial Flutter project setup
- Local SQLite database
- Basic cart system
- Product page
- Inventory page
- Transaction page

#### Product Management

- Add product
- Basic product edit
- Selling price
- Purchase price
- Initial stock
- Minimum stock
- Basic product unit

#### Inventory

- Add stock manually
- Reduce stock manually
- Stock adjustment notes
- Stock movement history
- Stock validation to prevent negative stock

#### Transaction

- Transaction cart
- Add product to cart
- Reduce cart item quantity
- Automatic total calculation
- Payment dialog
- Automatic change calculation
- Save transaction to database

#### Receipt

- Receipt preview
- Store information
- Transaction item details
- Payment summary

#### Settings

- Store name
- Store address
- Store phone number
- Receipt footer

### Improved

- Reusable currency formatter
- Reusable date formatter

### Fixed

- Fixed transaction quantity exceeding available stock
- Fixed inventory refresh after stock adjustment
- Fixed BuildContext usage after async operation
- Fixed currency formatting issues