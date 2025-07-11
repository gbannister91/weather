import { createElement } from 'lwc';
import GB_weatherDisplay from 'c/gb_weatherDisplay';
import getWeatherForContact from '@salesforce/apex/GB_weatherAccessor.getWeatherForContact';
import { subscribe, unsubscribe } from 'lightning/empApi';

// Mock implementations
jest.mock('@salesforce/apex/GB_weatherAccessor.getWeatherForContact', () => ({
default: jest.fn(() => Promise.resolve(null))
}), { virtual: true });

jest.mock('lightning/empApi', () => ({
subscribe: jest.fn(() => Promise.resolve({ id: 'mock-sub-id' })),
unsubscribe: jest.fn()
}));

// Sample weather data
const MOCK_WEATHER = {
GB_Temperature__c: 22,
GB_Description__c: 'Sunny',
GB_iconUrl__c: '/img.png'
};

// Helper function to wait for DOM updates
async function flushPromises() {
return new Promise((resolve) => setTimeout(resolve, 0));
}

describe('c-gb-weather-display', () => {
let element;
const RECORD_ID = '003XXXXXXXXXXXX';

beforeEach(() => {
// Reset mocks
jest.clearAllMocks();
getWeatherForContact.mockImplementation(() => Promise.resolve(null));
subscribe.mockImplementation(() => Promise.resolve({ id: 'mock-sub-id' }));

// Create component
element = createElement('c-gb-weather-display', {
is: GB_weatherDisplay
});
element.recordId = RECORD_ID;
document.body.appendChild(element);
});

afterEach(() => {
document.body.removeChild(element);
});

it('initializes correctly on connection', async () => {
await flushPromises();
expect(subscribe).toHaveBeenCalledWith(
'/event/GB_addressUpdated__e',
-1,
expect.any(Function)
);
expect(getWeatherForContact).toHaveBeenCalledWith({
contactId: RECORD_ID,
makeCallout: false
});
});

it('displays loading spinner during initial load', async () => {
// Delay Apex resolution
let resolveApex;
getWeatherForContact.mockReturnValue(new Promise(resolve => {
resolveApex = resolve;
}));

// Wait for initial rendering
await flushPromises();

// Verify spinner is visible
const spinner = element.shadowRoot.querySelector('lightning-spinner');
expect(spinner).not.toBeNull();
expect(spinner.alternativeText).toBe('Loading');

// Resolve Apex and verify spinner disappears
resolveApex(MOCK_WEATHER);
await flushPromises();
expect(element.shadowRoot.querySelector('lightning-spinner')).toBeNull();
});

it('renders weather data correctly', async () => {
getWeatherForContact.mockResolvedValue(MOCK_WEATHER);
await flushPromises();

// Verify temperature display
const tempContainer = element.shadowRoot.querySelector('.slds-text-title');
expect(tempContainer).not.toBeNull();
expect(tempContainer.textContent).toContain(`${MOCK_WEATHER.GB_Temperature__c} °C`);

// Verify description
const descElement = element.shadowRoot.querySelector('.slds-p-top_x-small lightning-formatted-text');
expect(descElement).not.toBeNull();
expect(descElement.value).toBe(MOCK_WEATHER.GB_Description__c);

// Verify icon
const img = element.shadowRoot.querySelector('img');
expect(img).not.toBeNull();
expect(img.src).toContain(MOCK_WEATHER.GB_iconUrl__c);
});

it('shows weather unavailable message', async () => {
getWeatherForContact.mockResolvedValue(null);
await flushPromises();

// Find the message using specific selector
const card = element.shadowRoot.querySelector('lightning-card');
expect(card).not.toBeNull();
expect(card.shadowRoot.textContent).toContain('Weather Unavailable');
});

it('triggers refresh via button click', async () => {
getWeatherForContact.mockResolvedValue(MOCK_WEATHER);
await flushPromises();

// Click refresh button
const refreshBtn = element.shadowRoot.querySelector('lightning-button-icon');
refreshBtn.click();

// Verify states and API call
expect(element.isRefreshing).toBe(true);
expect(getWeatherForContact).toHaveBeenCalledWith({
contactId: RECORD_ID,
makeCallout: true
});

// Wait for refresh to complete
await flushPromises();
expect(element.isRefreshing).toBe(false);
});

it('shows refresh spinner during reload', async () => {
getWeatherForContact.mockResolvedValue(MOCK_WEATHER);
await flushPromises();

// Click refresh button
const refreshBtn = element.shadowRoot.querySelector('lightning-button-icon');
refreshBtn.click();

// Verify refresh spinner is shown
const refreshSpinner = element.shadowRoot.querySelector('lightning-icon');
expect(refreshSpinner).not.toBeNull();
expect(refreshSpinner.iconName).toBe('utility:spinner');
expect(refreshSpinner.classList).toContain('slds-animate_spin');

// Clean up
await flushPromises();
});

it('processes relevant platform events', async () => {
await flushPromises();

// Access event callback
const [eventChannel, replayId, eventCallback] = subscribe.mock.calls[0];

// Trigger relevant event
eventCallback({
data: {
payload: { GB_contactId__c: RECORD_ID }
}
});

await flushPromises();
expect(getWeatherForContact).toHaveBeenCalledTimes(2);
});

it('ignores irrelevant platform events', async () => {
await flushPromises();

// Access event callback
const [eventChannel, replayId, eventCallback] = subscribe.mock.calls[0];

// Trigger irrelevant event
eventCallback({
data: {
payload: { GB_contactId__c: 'OTHER_RECORD' }
}
});

await flushPromises();
expect(getWeatherForContact).toHaveBeenCalledTimes(1);
});

it('cleans up subscriptions on disconnect', async () => {
await flushPromises();
document.body.removeChild(element);
await flushPromises();

expect(unsubscribe).toHaveBeenCalledWith(
{ id: 'mock-sub-id' },
expect.any(Function)
);
});

it('handles Apex errors gracefully', async () => {
getWeatherForContact.mockRejectedValue(new Error('API down'));
await flushPromises();

// Verify no spinner is shown
const spinner = element.shadowRoot.querySelector('lightning-spinner');
expect(spinner).toBeNull();
});
});
