# Delphi Coding Guidelines for Claude Code

## Environment & Target

- **Target**: Delphi 12.3 (RAD Studio 12.3 Athens)
- **Platform**: Windows VCL
- **Default Test Framework**: DUnitX
- **Collections Framework**: Spring4D
- **Dependency Injection**: Spring4D Container (preferred)

---

## Critical Rules

These rules are absolute and have no exceptions unless explicitly stated.

### NEVER Rules

- **NEVER use `initialization` and `finalization` sections** - All initialization must be explicit in constructors or factory methods; cleanup in destructors
- **NEVER create global functions or procedures** - Always use class methods or interfaces instead
- **NEVER use comments** - Code should be self-documenting through clear naming and structure
- **NEVER use `with` statements** - Always use explicit object references
- **NEVER call DFM event handlers directly** - Create separate business logic methods and call those from both event handlers and code
- **NEVER use var parameters** - Only exception: unavoidable record parameter cases
- **NEVER use prefixes for parameters and local variables** - No `A`, `L`, `V` or similar prefixes
- **NEVER swallow exceptions** - Always re-raise, wrap to specific exception, or handle/log
- **NEVER use System.Generics.Collections** - Use Spring.Collections instead
- **NEVER repeat string literals** - If text appears 2×, move to constant or resourcestring

### ALWAYS Rules

- **ALWAYS use const for parameters** - All parameters that won't be modified must use const
- **ALWAYS use const for immutable inline variables** - Prefer `const` over `var` for values that don't change
- **ALWAYS use inline variable declarations** - Never declare variables at the top of procedures/functions
- **ALWAYS use interface references** - When a class implements an interface, use the interface type for automatic memory management
- **ALWAYS use Spring collections** - Use `IList<T>`, `IDictionary<K,V>` instead of `TArray<T>` or `TList<T>`
- **ALWAYS use qualified enum values** - Use scoped enums with `TEnumType.Value` syntax
- **ALWAYS protect manual resource cleanup with try-finally** - Any object requiring manual Free must be in try-finally block
- **ALWAYS use type prefixes** - `T` for classes/records, `I` for interfaces, `F` for class fields
- **ALWAYS use parentheses around boolean expressions** - When storing boolean results in variables

### Compilation Requirements

- **No hints or warnings allowed** - Code must compile cleanly to ensure code quality and prevent masking real problems
- **Respect external library conventions** - Follow original naming and patterns of libraries like DUnitX, Spring4D

---

## Naming Conventions

### General Principles

All names (variables, methods, classes, interfaces, parameters, etc.) must be:
- **Meaningful and descriptive** - Reveal intent and purpose
- **PascalCase** - Exception: Delphi keywords remain lowercase (begin, end, if, then, var, const, etc.)
- **Pronounceable and searchable**
- **Free of disinformation and noise words** - Avoid variable types or generic words like Data, Manager, Info

```delphi
// ❌ Bad - unclear, uses type in name, single letter
var d: TData;
var i: Integer;
var UserMgr: TManager;

// ✅ Good - clear intent, descriptive
var CustomerCount: Integer;
var OrderTotal: Currency;
var ValidationResult: TValidationResult;
```

### Avoid Numbers in Names

Do not use numbers in identifiers except for version numbers where clearly indicated.

```delphi
// ❌ Bad
Button1: TButton;
procedure ProcessMethod2;

// ✅ Good
ButtonSave: TButton;
procedure ProcessOrderValidation;
```

### Type Prefixes

```delphi
// ✅ Classes and Records: T prefix
type
  TCustomer = class
  TOrderData = record

// ✅ Interfaces: I prefix
type
  ICustomerRepository = interface

// ✅ Class fields: F prefix
private
  FCustomerName: string;
  FOrderCount: Integer;

// ✅ Parameters and local variables: NO prefix
procedure ProcessOrder(const OrderId: Integer; const CustomerName: string);
begin
  const TotalAmount := CalculateTotal(OrderId);
end;

// ❌ Bad - prefixes on parameters
procedure ProcessOrder(const AOrderId: Integer; const ACustomerName: string);
```

### Component Naming

Components must:
- Use PascalCase
- Start with component type
- Reflect location context (tab/panel) for clarity

```delphi
// ✅ Good
ButtonSave: TButton;
EditCustomerName: TEdit;
PanelCustomerButtonSave: TButton;  // Save button in Customer panel
GridOrdersTabMain: TDBGrid;        // Grid in Main tab of Orders

// ❌ Bad
Button1: TButton;
Edit1: TEdit;
SaveBtn: TButton;
```

### Resourcestrings

Use PascalCase without prefixes. Treat as ordinary constant identifiers.

```delphi
// ❌ Bad - unnecessary prefixes
const
  SErrorMessage = 'An error occurred';
  RS_WARNING = 'Warning';
  STR_CONFIRM = 'Confirm action';

// ✅ Good - clear, no prefix
resourcestring
  ErrorMessage = 'An error occurred';
  WarningMessage = 'Warning';
  ConfirmAction = 'Confirm action';
```

### Unit and File Naming

Names use dot notation formatted as: **[Module].[Entity].[Purpose].[Specification].pas**

- **Intention-revealing names** - Be specific about purpose
- **Use namespaces** - Separate concerns with dots
- **Avoid reserved words** - Don't use Delphi keywords in unit names

```delphi
// ❌ Bad - too vague
Service.Provider.pas

// ✅ Good - clear intent
Service.User.Provider.pas
Service.User.Provider.LDAP.pas

// ❌ Bad - reserved word
Service.Initialization.pas

// ✅ Good - avoid reserved word
Service.InitializationHelper.pas

// ✅ Interface files
Service.User.Provider.Interfaces.pas

// ✅ Test files
Service.User.Provider.Tests.pas
Service.User.Provider.LDAP.Tests.pas
```

---

## Type Definitions

### Classes

- **One class per file** - Each class gets its own unit file
- **Always T prefix** - All class names start with T
- **File name matches class name** - TCustomerService in CustomerService.pas

```delphi
// File: Service.Customer.pas
unit Service.Customer;

interface

type
  TCustomerService = class
  private
    FRepository: ICustomerRepository;
    
  public
    constructor Create(const Repository: ICustomerRepository);
    function GetById(const CustomerId: Integer): ICustomer;
  end;

implementation

end.
```

### Interfaces

- **Multiple related interfaces per file allowed** - Interfaces for same entity can share file
- **Always I prefix** - All interface names start with I
- **Separate from implementations** - Interfaces in [Name].Interfaces.pas files
- **GUID required** - Directly under interface declaration with blank line before first method

```delphi
// File: Service.User.Provider.Interfaces.pas
unit Service.User.Provider.Interfaces;

interface

type
  IUserRepository = interface
    ['{081933C5-F510-417A-943E-4336409BFADD}']

    function GetByMetaData(const MetaData: IMetaData): IUser;
    function GetById(const UserId: Integer): IUser;
  end;

  IUserValidator = interface
    ['{2A4B6C8D-E1F3-4567-89AB-CDEF01234567}']

    function Validate(const User: IUser): TValidationResult;
  end;

implementation

end.
```

### Enums

Always use scoped enums with qualified values. No prefixes in enum value names.

```delphi
// ✅ Good - scoped enum, no prefixes in values
type
  {$SCOPEDENUMS ON}
  TOrderStatus = (New, Processed, Invoiced, Paid);
  {$SCOPEDENUMS OFF}

// Usage
var Status := TOrderStatus.New;
if Status = TOrderStatus.Processed then
  ProcessOrder;

// ❌ Bad - non-scoped, prefixed values
type
  TOrderStatus = (osNew, osProcessed, osInvoiced, osPaid);
```

### Records

- **Always T prefix** - Consistent with classes
- **Use for data structures** - Records for value types and DTOs

```delphi
type
  TOrderData = record
    OrderId: Integer;
    CustomerName: string;
    TotalAmount: Currency;
  end;
```

### Constants

- **PascalCase for all constants** - Consistent with general naming
- **Group related constants** - Use record with const section when many constants serve single purpose

```delphi
// ✅ Good - single constant
const
  MaxRetryAttempts = 3;
  DefaultTimeout = 5000;

// ✅ Good - grouped related constants
type
  TDatabaseConfig = record
  const
    MaxConnections = 100;
    DefaultTimeout = 30;
    RetryAttempts = 3;
    ConnectionString = 'Server=localhost;Database=MyDB';
  end;

// ❌ Bad - UPPERCASE constants
const
  MAX_RETRY_ATTEMPTS = 3;
  DEFAULT_TIMEOUT = 5000;
```

---

## Variables & Parameters

### Inline Variables (Mandatory)

Always declare variables inline at point of first use. Never declare at top of procedure.

#### Syntax Rules

Inline variable declarations use different assignment operators:

- **const** uses `=` (single equals, no colon)
- **var** uses `:=` (colon-equals)

```delphi
// ✅ Correct inline const - uses =
const CustomerName = GetCustomerName(CustomerId);
const IsValid = (Count > 0);
const TotalAmount = CalculateTotal(OrderId);

// ✅ Correct inline var - uses :=
var Counter := 0;
var Result := ProcessData(Input);

// ❌ Wrong - const should not use :=
const Orders := FRepository.GetActiveOrders;

// ❌ Wrong - var should not use =
var Counter = 0;
```

**Rationale:** Inline const declares compile-time constants with type inference, while inline var declares runtime variables. The different operators reflect this semantic distinction.

```delphi
// ✅ Good - inline declarations
procedure ProcessOrders;
begin
  const Orders = FRepository.GetActiveOrders;

  for var Order in Orders do
  begin
    const IsValid = ValidateOrder(Order);
    if IsValid then
      ProcessOrder(Order);
  end;
end;

// ❌ Bad - variables at top
procedure ProcessOrders;
var
  Orders: IList<IOrder>;
  Order: IOrder;
  IsValid: Boolean;
begin
  Orders := FRepository.GetActiveOrders;
  
  for Order in Orders do
  begin
    IsValid := ValidateOrder(Order);
    if IsValid then
      ProcessOrder(Order);
  end;
end;
```

### Const for Immutable Values

Use `const` for inline variables that won't change and for all parameters.

```delphi
// ✅ Good - const for immutable inline variable
const HasOrders := (Orders.Count > 0);
if HasOrders then
  ProcessOrders;

// ✅ Good - const for clarifying variable
const CustomerName := Edit.Text.Trim;
if CustomerName.IsEmpty then
  Exit;

// ❌ Bad - var when value doesn't change
var HasOrders := (Orders.Count > 0);
```

### Boolean Expressions with Parentheses

Always use parentheses around boolean expressions stored in variables.

```delphi
// ✅ Good - parentheses for clarity
const IsValid := (Count > 0);
const HasData := (Orders.Count > 0) and (not Orders.IsEmpty);
const CanProcess := (Status = TOrderStatus.New);

// ❌ Bad - no parentheses
const IsValid := Count > 0;
const HasData := Orders.Count > 0 and not Orders.IsEmpty;
```

### Parameters

All parameters must use `const` unless the parameter needs to be modified (rare).

```delphi
// ✅ Good - const parameters
function CreateOrder(const CustomerId: Integer; 
                     const OrderDate: TDateTime; 
                     const Items: IList<IOrderItem>): IOrder;

constructor TCustomerService.Create(const Repository: ICustomerRepository; 
                                   const Logger: ILogger);

// ❌ Bad - no const
function CreateOrder(CustomerId: Integer; 
                     OrderDate: TDateTime; 
                     Items: IList<IOrderItem>): IOrder;
```

### Avoid Out Parameters

Only use `out` parameters for `TryGet` style functions. Never use `var` parameters except for unavoidable record cases.

```delphi
// ✅ Good - TryGet pattern with out
function TryGetCustomer(const CustomerId: Integer; 
                       out Customer: ICustomer): Boolean;

// ✅ Good - return value instead of out
function GetCustomerName(const CustomerId: Integer): string;

// ❌ Bad - unnecessary out parameter
function GetCustomerName(const CustomerId: Integer; 
                        out CustomerName: string): Boolean;

// ❌ Bad - var parameter
procedure UpdateTotal(var Total: Currency);
```

---

## Control Flow & Structure

### For Loops

- Prefer `for..in` over classical `for` loop
- Use classical `for` only when counting/indexing is necessary
- Every for loop always has `begin/end`

```delphi
// ✅ Good - for..in with begin/end
for var Customer in Customers do
begin
  ProcessCustomer(Customer);
end;

// ✅ Good - classical for when index needed
for var Index := 0 to Items.Count - 1 do
begin
  ProcessItem(Items[Index], Index);
end;

// ❌ Bad - classical for without need
for var Index := 0 to Customers.Count - 1 do
begin
  ProcessCustomer(Customers[Index]);
end;

// ❌ Bad - missing begin/end
for var Customer in Customers do
  ProcessCustomer(Customer);
```

### If Statements

- Use `begin/end` unless entire body is exactly one statement on one line
- `begin` must start on a new line
- Complex expressions must use descriptive boolean variable
- Comparisons and calculations always via variable

```delphi
// ✅ Good - single line without begin/end
if CustomerName.IsEmpty then
  Exit;

// ✅ Good - multiple statements with begin/end
if CustomerName.IsEmpty then
begin
  ShowError('Name required');
  Exit;
end;

// ✅ Good - complex expression via variable
const HasOrders := (Orders.Count > 0);
if HasOrders then
  ProcessOrders;

// ✅ Good - comparison via variable
const IsExpired := (ExpiryDate < Now);
if IsExpired then
  HandleExpiration;

// ✅ Good - simple property check
if Name.Trim.IsEmpty then
  Exit;

// ❌ Bad - comparison without variable
if Orders.Count > 0 then
  ProcessOrders;

// ❌ Bad - calculation without variable  
if Name.Length > 5 then
  ValidateName;

// ❌ Bad - begin on same line
if HasOrders then begin
  ProcessOrders;
end;
```

### Guard Clauses

Use guard clauses with early exits. Complex expressions via inline boolean variables.

```delphi
// ✅ Good - guard clause with inline variable
function ProcessOrder(const Order: IOrder): Boolean;
begin
  Result := False;
  
  const IsInvalid := (Order = nil) or (Order.Id = 0);
  if IsInvalid then
    Exit;
    
  const AlreadyProcessed := FRepository.Contains(Order.Id);
  if AlreadyProcessed then
    Exit;
    
  // Main processing logic
  ProcessOrderInternal(Order);
  Result := True;
end;

// ✅ Good - simple guard with Result
function GetCustomerName(const CustomerId: Integer): string;
begin
  Result := '';
  
  const Customer := FRepository.GetById(CustomerId);
  if Customer = nil then
    Exit;
    
  Result := Customer.Name;
end;

// ❌ Bad - nested conditions instead of guards
function ProcessOrder(const Order: IOrder): Boolean;
begin
  if (Order <> nil) and (Order.Id <> 0) then
  begin
    if not FRepository.Contains(Order.Id) then
    begin
      ProcessOrderInternal(Order);
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;
```

### Begin/End Formatting

`begin` always starts on a new line.

```delphi
// ✅ Good
if HasData then
begin
  ProcessData;
end;

for var Item in Items do
begin
  ProcessItem(Item);
end;

// ❌ Bad - begin on same line
if HasData then begin
  ProcessData;
end;
```

### Class Section Ordering

**Interface section ordering:**
- private (fields first, then private methods)
- protected (only if needed)
- public (class methods → constructor/destructor → methods → properties)
- Blank lines between sections

**Within public section:**
1. Static/class methods first
2. Constructor/destructor
3. Regular instance methods
4. Properties last

**Interface section follows call order where possible.** Implementation section follows strict call order.

```delphi
// ✅ Good - proper class section ordering
type
  TUserRepository = class(TInterfacedObject, IUserRepository)
  private
    FMetaData: IMetaData;
    
    function ReadFromDatabase: IUser;

  protected
    function GetName: string;

  public 
    class function GetInstance: IUserRepository;
   
    constructor Create(const DatabaseLayer: IDatabaseLayer);
    destructor Destroy; override;

    function GetById(const Id: Integer): IUser;

    property Name: string read GetName;
  end;
```

### Method Ordering (Top-to-Bottom)

**Implementation section:** Methods appear in strict call order. Called methods (helpers) always appear below their callers.

**Rationale**: Creates natural reading flow from high-level overview to low-level implementation details. No searching backwards to find called methods.

```delphi
// ✅ Good - implementation follows top-to-bottom execution flow
procedure TOrderService.ProcessCustomerOrders(const CustomerId: Integer);
begin
  const Orders := GetCustomerOrders(CustomerId);
  
  for var Order in Orders do
  begin
    ValidateOrder(Order);
    SaveOrder(Order);
  end;
end;

function TOrderService.GetCustomerOrders(const CustomerId: Integer): IList<IOrder>;
begin
  Result := FRepository.GetByCustomerId(CustomerId);
end;

procedure TOrderService.ValidateOrder(const Order: IOrder);
begin
  // validation logic
end;

procedure TOrderService.SaveOrder(const Order: IOrder);
begin
  FRepository.Save(Order);
end;
```

---

## String Handling

### Internal String Usage

Always work internally with `string` (UnicodeString). Convert only at boundaries.

### ANSI/Unicode Conversions

Use RTL functions or type assignments. Never use manual pointer manipulation.

```delphi
// ✅ Good - RTL conversions
var UnicodeText: string := 'Hello';
var AnsiText: AnsiString := AnsiString(UnicodeText);
var BackToUnicode: string := string(AnsiText);

// ✅ Good - UTF8 conversion
var Utf8Text: UTF8String := UTF8String(UnicodeText);
var FromUtf8: string := UTF8ToString(Utf8Text);

// ❌ Bad - manual pointer manipulation
var P: PAnsiChar := PAnsiChar(UnicodeText);  // Wrong!
```

### PAnsiChar and PWideChar

- Unicode → PAnsiChar: always through AnsiString intermediary
- PWideChar can be obtained directly from string (be aware of lifetime)

```delphi
// ✅ Good - via AnsiString intermediary
var UnicodeText: string := 'Hello';
var AnsiText: AnsiString := AnsiString(UnicodeText);
var AnsiPtr: PAnsiChar := PAnsiChar(AnsiText);

// ✅ Good - PWideChar directly (watch lifetime!)
var UnicodeText: string := 'Hello';
var WidePtr: PWideChar := PWideChar(UnicodeText);
```

### Avoid Pointers

Avoid pointers (@, ^, direct casting to PAnsiChar/PWideChar) where possible.

### No Repeated String Literals

If text appears 2×, move to constant or resourcestring.

```delphi
// ❌ Bad - repeated literals
ShowMessage('Customer not found');
LogError('Customer not found');

// ✅ Good - resourcestring for UI text
resourcestring
  CustomerNotFound = 'Customer not found';

procedure ShowCustomerError;
begin
  ShowMessage(CustomerNotFound);
  LogError(CustomerNotFound);
end;

// ✅ Good - const for non-UI text
const
  DefaultConnectionString = 'Server=localhost;Database=MyDB';
```

### Multi-line Strings

Follow this exact pattern for multi-line strings:

```delphi
procedure SendEmail;
begin
  const Lines: TArray<string> = [
    'Dear {0},',
    '',
    'Your order #{1} has been processed.',
    'Total amount: {2}',
    '',
    'Thank you for your business.'
  ];
  
  const EmailBody := string.Join(sLineBreak, Lines);
  
  const Args: TArray<TVarRec> = [
    CustomerName,
    OrderId,
    FormatFloat('0.00', TotalAmount)
  ];
  
  const FormattedBody := Format(EmailBody, Args);
  
  SendEmailMessage(FormattedBody);
end;
```

### Avoid Complex Expressions

Split long or complex chained expressions into meaningful intermediate variables.

```delphi
// ✅ Good - intermediate variables
const TrimmedName := Customer.Name.Trim;
const UpperName := TrimmedName.ToUpper;
const IsValid := not UpperName.IsEmpty;

// ❌ Bad - method chaining (trainwreck)
const IsValid := not Customer.Name.Trim.ToUpper.IsEmpty;

// ✅ Good - separate steps
const Orders := Repository.GetActiveOrders;
const ValidOrders := FilterValidOrders(Orders);
const TotalAmount := CalculateTotal(ValidOrders);

// ❌ Bad - chained methods
const TotalAmount := CalculateTotal(FilterValidOrders(Repository.GetActiveOrders));
```

---

## Exception Handling

### Never Swallow Exceptions

In `try..except` blocks, always do something: re-raise, wrap to specific exception, or handle/log.

```delphi
// ✅ Good - re-raise with context
try
  ProcessOrder(Order);
except
  on E: Exception do
  begin
    LogError('Order processing failed', E);
    raise;
  end;
end;

// ✅ Good - wrap to specific exception
try
  ConnectToDatabase;
except
  on E: Exception do
    raise EDatabaseConnectionError.Create('Connection failed', E);
end;

// ✅ Good - handle and continue
try
  SendNotification(Customer);
except
  on E: Exception do
  begin
    LogWarning('Notification failed, continuing', E);
    // Continue processing
  end;
end;

// ❌ Bad - swallowing exception
try
  ProcessOrder(Order);
except
  // Silent failure!
end;
```

### Try-Finally for Resources

Use `try..finally` for resource lifecycle where appropriate. Objects requiring manual `Free` must be protected.

**When try-finally is needed:**
- Database objects (TFDQuery, TFDConnection, etc.)
- HTTP clients and requests
- File handles and streams
- Any object created with `.Create()` without interface reference counting

**When try-finally is NOT needed:**
- Interface references (automatic reference counting)
- Spring collections (IList, IDictionary)
- Any TInterfacedObject-based class used via interface

```delphi
// ✅ Good - protected resource cleanup
procedure QueryDatabase;
begin
  var Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT * FROM Customers';
    Query.Open;
    ProcessResults(Query);
  finally
    Query.Free;
  end;
end;

// ✅ Good - interface reference (no try-finally needed)
procedure ProcessCustomers;
begin
  var Customers: IList<ICustomer> := FRepository.GetAll;
  
  for var Customer in Customers do
    ProcessCustomer(Customer);
    
  // No Free needed - automatic cleanup via reference counting
end;

// ✅ Good - TInterfacedObject via interface (no try-finally needed)
procedure InitializeService;
begin
  var CustomerService: ICustomerService := TCustomerService.Create(FRepository);
  
  CustomerService.ProcessOrders;
  
  // No Free needed - automatic cleanup
end;

// ❌ Bad - missing try-finally for manual resource
procedure QueryDatabase;
begin
  var Query := TFDQuery.Create(nil);
  Query.Connection := FConnection;
  Query.SQL.Text := 'SELECT * FROM Customers';
  Query.Open;
  ProcessResults(Query);
  Query.Free;  // ⚠️ Never executed if exception occurs!
end;
```

---

## Architecture & Design Principles

### SOLID Principles

Apply SOLID principles in all code:
- **Single Responsibility** - A class should have one reason to change
- **Open-Closed** - Open for extension, closed for modification
- **Liskov Substitution** - Subtypes must be substitutable for their base types
- **Interface Segregation** - Many specific interfaces better than one general interface
- **Dependency Inversion** - Depend on abstractions, not concretions

### No Global State

Do not use global variables or global state. All state should be encapsulated in classes.

### Explicit Dependencies

Make dependencies explicit through dependency injection. Do not hide dependencies.

```delphi
// ✅ Good - explicit dependencies via constructor
type
  TCustomerService = class(TInterfacedObject, ICustomerService)
  private
    FRepository: ICustomerRepository;
    FLogger: ILogger;
    
  public
    constructor Create(const Repository: ICustomerRepository; 
                      const Logger: ILogger);
  end;

// ❌ Bad - hidden global dependency
type
  TCustomerService = class
  public
    procedure ProcessOrder(const Order: IOrder);
  end;

procedure TCustomerService.ProcessOrder(const Order: IOrder);
begin
  GlobalLogger.Log('Processing order');  // Hidden dependency!
  GlobalRepository.Save(Order);          // Hidden dependency!
end;
```

### Dependency Container

Use a dependency container, preferably from Spring4D framework. Do not pass the container into classes as a dependency.

```delphi
// ✅ Good - register and resolve via container
procedure RegisterServices;
begin
  GlobalContainer.RegisterType<ICustomerRepository, TCustomerRepository>;
  GlobalContainer.RegisterType<ILogger, TFileLogger>;
  GlobalContainer.RegisterType<ICustomerService, TCustomerService>;
end;

procedure InitializeApplication;
begin
  var CustomerService := GlobalContainer.Resolve<ICustomerService>;
  CustomerService.Initialize;
end;

// ❌ Bad - passing container as dependency
type
  TCustomerService = class
  private
    FContainer: TContainer;  // Don't do this!
    
  public
    constructor Create(const Container: TContainer);
  end;
```

### Keep Classes and Methods Small

Keep classes and methods as small as possible in scope and context. Each should have a clear, focused responsibility.

### Single Abstraction Layer

Methods should operate at a single level of abstraction. Do not mix high-level and low-level operations.

**Rationale**: Mixing abstraction levels makes code harder to understand and violates Single Responsibility Principle. Each method should tell a coherent story at one level of detail.

```delphi
// ✅ Good - single abstraction level (high-level coordination)
procedure TOrderService.ProcessOrder(const Order: IOrder);
begin
  ValidateOrder(Order);
  CalculateTotals(Order);
  SaveOrder(Order);
  SendConfirmation(Order);
end;

// ✅ Good - single abstraction level (low-level details)
procedure TOrderService.CalculateTotals(const Order: IOrder);
begin
  var SubTotal := 0.0;
  
  for var Item in Order.Items do
    SubTotal := SubTotal + (Item.Quantity * Item.UnitPrice);
    
  Order.SubTotal := SubTotal;
  Order.Tax := SubTotal * TaxRate;
  Order.Total := SubTotal + Order.Tax;
end;

// ❌ Bad - mixed abstraction levels
procedure TOrderService.ProcessOrder(const Order: IOrder);
begin
  // High-level
  ValidateOrder(Order);
  
  // Suddenly low-level details!
  var SubTotal := 0.0;
  for var Item in Order.Items do
    SubTotal := SubTotal + (Item.Quantity * Item.UnitPrice);
  Order.SubTotal := SubTotal;
  Order.Tax := SubTotal * 0.21;
  
  // Back to high-level
  SaveOrder(Order);
  SendConfirmation(Order);
end;
```

---

## Collections & Memory Management

### Always Use Spring Collections

Use Spring Framework collections instead of System.Generics.Collections or dynamic arrays.

**Why Spring Collections:**
- Automatic memory management via interface reference counting
- No manual `SetLength` calls needed
- No manual `Free` needed
- Consistent interface-based API

```delphi
// ✅ Good - Spring collections
uses
  Spring.Collections;

function GetActiveCustomers: IList<ICustomer>;
begin
  Result := TCollections.CreateList<ICustomer>;
  
  for var Customer in FAllCustomers do
  begin
    const IsActive := Customer.Status = TCustomerStatus.Active;
    if IsActive then
      Result.Add(Customer);
  end;
end;

// ✅ Good - dictionary
function BuildCustomerLookup: IDictionary<Integer, ICustomer>;
begin
  Result := TCollections.CreateDictionary<Integer, ICustomer>;
  
  for var Customer in GetAllCustomers do
    Result.Add(Customer.Id, Customer);
end;

// ❌ Bad - System.Generics.Collections
uses
  System.Generics.Collections;

function GetActiveCustomers: TList<ICustomer>;
begin
  Result := TList<ICustomer>.Create;  // Manual memory management!
  // ...
end;

// ❌ Bad - dynamic arrays
function GetActiveCustomers: TArray<ICustomer>;
begin
  SetLength(Result, 0);  // Manual array growth!
  // ...
end;
```

### Interface References for Memory Management

When a class implements an interface, always use interface references to enable automatic memory management via reference counting.

```delphi
// ✅ Good - interface reference, automatic cleanup
procedure ProcessCustomers;
begin
  var Repository: ICustomerRepository := TCustomerRepository.Create;
  var Customers := Repository.GetAll;
  
  for var Customer in Customers do
    ProcessCustomer(Customer);
    
  // No Free needed - automatic cleanup
end;

// ✅ Good - TInterfacedObject with interface
type
  ICustomerService = interface
    ['{12345678-1234-1234-1234-123456789012}']
    
    procedure ProcessOrders;
  end;

  TCustomerService = class(TInterfacedObject, ICustomerService)
  public
    procedure ProcessOrders;
  end;

var Service: ICustomerService := TCustomerService.Create;
// No Free needed

// ❌ Bad - object reference requires manual Free
procedure ProcessCustomers;
begin
  var Repository := TCustomerRepository.Create;
  try
    var Customers := Repository.GetAll;
    // Process customers
  finally
    Repository.Free;  // Manual memory management
  end;
end;
```

---

## Unit Testing

### Test Framework

Use DUnitX as the default test framework.

### Test File Organization

- Test files use `.Tests.pas` postfix
- Test files in same directory as source unit being tested
- Test unit name matches source unit name with `.Tests` postfix

```
// Source unit
Service.Customer.pas

// Test unit (same directory)
Service.Customer.Tests.pas
```

### Test Structure

Focus on public behavior with clear names using arrange/act/assert structure.

```delphi
unit Service.Customer.Tests;

interface

uses
  DUnitX.TestFramework,
  Service.Customer.Interfaces,
  Service.Customer;

type
  [TestFixture]
  TCustomerServiceTests = class
  private
    FService: ICustomerService;
    
  public
    [Setup]
    procedure Setup;
    
    [TearDown]
    procedure TearDown;
    
    [Test]
    procedure GetById_ValidId_ReturnsCustomer;
    
    [Test]
    procedure GetById_InvalidId_ReturnsNil;
  end;

implementation

procedure TCustomerServiceTests.Setup;
begin
  FService := TCustomerService.Create;
end;

procedure TCustomerServiceTests.TearDown;
begin
  FService := nil;
end;

procedure TCustomerServiceTests.GetById_ValidId_ReturnsCustomer;
begin
  // Arrange
  const CustomerId := 1;
  
  // Act
  const Customer := FService.GetById(CustomerId);
  
  // Assert
  Assert.IsNotNull(Customer);
  Assert.AreEqual(CustomerId, Customer.Id);
end;

procedure TCustomerServiceTests.GetById_InvalidId_ReturnsNil;
begin
  // Arrange
  const InvalidId := -1;
  
  // Act
  const Customer := FService.GetById(InvalidId);
  
  // Assert
  Assert.IsNull(Customer);
end;
```

### Test Cases (Parameterized Tests)

Use test cases where possible for testing multiple scenarios.

```delphi
[Test]
[TestCase('Positive', '5,10,15')]
[TestCase('Negative', '-5,-10,-15')]
[TestCase('Mixed', '5,-10,-5')]
procedure Add_VariousInputs_ReturnsCorrectSum(const Value1, Value2, Expected: Integer);
begin
  // Act
  const Actual := FCalculator.Add(Value1, Value2);
  
  // Assert
  Assert.AreEqual(Expected, Actual);
end;
```

### Assertions

- Prefer `Assert.AreEqual` (use generic variant if needed)
- Use Expected and Actual variables with order: Expected, Actual
- Do not hide equality in `IsTrue/IsFalse`

```delphi
// ✅ Good - AreEqual with clear variables
procedure TestCalculation;
begin
  const Expected := 15;
  const Actual := FCalculator.Add(5, 10);
  
  Assert.AreEqual(Expected, Actual);
end;

// ✅ Good - generic AreEqual for custom types
procedure TestCustomerName;
begin
  const Expected := 'John Doe';
  const Actual := FCustomer.Name;
  
  Assert.AreEqual<string>(Expected, Actual);
end;

// ❌ Bad - hiding equality in IsTrue
procedure TestCalculation;
begin
  Assert.IsTrue(FCalculator.Add(5, 10) = 15);  // Don't do this!
end;
```

### Mocking Limitations

Spring4D mocking does not support methods with `out` parameters. Create a Fake class instead and state this limitation explicitly when encountered.

```delphi
// When encountering method with out parameter:
// Note: Spring4D mocking doesn't support out parameters.
// Creating a Fake class instead.

type
  TFakeCustomerRepository = class(TInterfacedObject, ICustomerRepository)
  private
    FReturnValue: Boolean;
    FCapturedCustomer: ICustomer;
    
  public
    function TryGetById(const CustomerId: Integer; 
                       out Customer: ICustomer): Boolean;
                       
    property ReturnValue: Boolean read FReturnValue write FReturnValue;
    property CapturedCustomer: ICustomer read FCapturedCustomer;
  end;
```

---

## Code Organization & Formatting

### Class Section Organization

Always declare `private` section before `public` section with blank line between them.

```delphi
// ✅ Good - private before public, blank line separator
type
  TCustomerService = class
  private
    FRepository: ICustomerRepository;
    FLogger: ILogger;
    
    procedure ValidateCustomer(const Customer: ICustomer);

  public
    constructor Create(const Repository: ICustomerRepository; 
                      const Logger: ILogger);
    function GetById(const CustomerId: Integer): ICustomer;
  end;

// ❌ Bad - no blank line, wrong order
type
  TCustomerService = class
  public
    constructor Create(const Repository: ICustomerRepository);
  private
    FRepository: ICustomerRepository;
  end;
```

### Method Signature Formatting

Place complete signature on one line if ≤200 characters. If longer, place first parameter on same line as function name, then align subsequent parameters.

```delphi
// ✅ Good - signature fits on one line
function TUserRepository.GetByMetaData(const MetaData: IMetaData): IUser;

// ✅ Good - signature too long, parameters aligned
function TUserRepository.GetByMetadata(const Name: string;
                                       const DayOfBirth: TDateTime;
                                       const NbOfChildren: Integer;
                                       const Status: TUserStatus): IUser;

// ❌ Bad - parameters not aligned
function TUserRepository.GetByMetadata(const Name: string;
  const DayOfBirth: TDateTime;
  const NbOfChildren: Integer;
  const Status: TUserStatus): IUser;
```

### Attribute Formatting

After a method attribute, the method must be on the next line.

```delphi
// ✅ Good - attribute on separate line
[Test]
procedure TestCustomerValidation;

[TestCase('Valid', 'John,Doe,true')]
[TestCase('Invalid', ',,false')]
procedure TestNameValidation(const FirstName, LastName: string;
                             const Expected: Boolean);

// ❌ Bad - method on same line as attribute
[Test] procedure TestCustomerValidation;
```

### Parameter Attributes Formatting

When parameters have attributes, keep the attribute and parameter together on the same line. Apply the same alignment rules as for regular parameters: if the signature fits on one line (≤200 characters), use one line. Otherwise, place the first parameter (with its attribute) on the same line as the method name, and align subsequent parameters (with their attributes) underneath.

**Key principle**: The attribute is part of the parameter declaration and must stay with its parameter.

```delphi
// ✅ Good - signature fits on one line
[ForAll(100)]
procedure TestStringReverse([StringAlpha('Text', 0, 50)] const Text: string);

// ✅ Good - signature too long, parameters with attributes aligned
[ForAll(100)]
procedure TestAdditionIsCommutative([IntRange('A', -1000, 1000)] const A: Integer;
                                    [IntRange('B', -1000, 1000)] const B: Integer);

// ✅ Good - complex example with multiple parameters
[ForAll(100)]
procedure TestCalculation([IntRange('Value', -1000, 1000)] const Value: Integer;
                          [StringAlpha('Name', 1, 50)] const Name: string;
                          [IntPositive('Count', 100)] const Count: Integer);

// ❌ Bad - attributes separated from parameters
[ForAll(100)]
procedure TestAdditionIsCommutative(
  [IntRange('A', -1000, 1000)] const A: Integer;
  [IntRange('B', -1000, 1000)] const B: Integer
);

// ❌ Bad - inconsistent alignment
[ForAll(100)]
procedure TestAdditionIsCommutative([IntRange('A', -1000, 1000)] const A: Integer;
  [IntRange('B', -1000, 1000)] const B: Integer);
```

### Used Units Formatting

Every used unit must be on a separate line.

```delphi
// ✅ Good - one unit per line
uses
  System.SysUtils,
  System.Classes,
  Spring.Collections,
  Service.Customer.Interfaces,
  Service.Customer;

// ❌ Bad - multiple units per line
uses
  System.SysUtils, System.Classes,
  Spring.Collections, Service.Customer.Interfaces;
```

### Blank Lines for Readability

Use blank lines between functional blocks of code for readability. Don't add excessive blank lines (maximum 1-2 consecutive).

```delphi
// ✅ Good - logical separation
procedure ProcessCustomerOrder;
begin
  const Customer := GetCustomer(CustomerId);
  const IsValid := ValidateCustomer(Customer);
  if not IsValid then
    Exit;
    
  const Order := CreateOrder(Customer);
  CalculateTotals(Order);
  
  SaveOrder(Order);
  SendConfirmation(Customer, Order);
end;

// ❌ Bad - no separation or too much separation
procedure ProcessCustomerOrder;
begin
  const Customer := GetCustomer(CustomerId);
  const IsValid := ValidateCustomer(Customer);
  if not IsValid then
    Exit;
  const Order := CreateOrder(Customer);
  CalculateTotals(Order);
  SaveOrder(Order);


  SendConfirmation(Customer, Order);
end;
```

---

## Context Awareness During Development

**Note**: This section requires clarification on specific use case and applicability.

When working on forms, always identify the specific context:

- Determine which tab, panel, or section of the form is being modified
- Search for and list all UI components that belong to that specific context (buttons, edits, grids, etc.)
- Verify component ownership by checking their naming patterns (e.g., btnVerifyOD1 for Tab1, btnVerifyOD2 for Tab2)
- When the story mentions a specific tab or panel name, ONLY use components that belong to that context
- If unsure about which components belong to the context, ask for clarification before proceeding
- Example: If working on "te verifiëren lenzen" tab, first identify all components with matching suffixes or located within that tab's container

---

## Summary

These guidelines ensure:
- **Consistent code style** across the entire codebase
- **Self-documenting code** through clear naming and structure
- **Robust error handling** without silent failures
- **Automatic memory management** through interfaces and Spring collections
- **Testable architecture** with explicit dependencies and SOLID principles
- **Maintainable code** with single responsibility and clear abstraction levels

Follow these guidelines strictly to produce high-quality, maintainable Delphi code that Claude Code can generate effectively.