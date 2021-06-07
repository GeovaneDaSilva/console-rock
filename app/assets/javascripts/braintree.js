$(document).on('turbolinks:load', function() {
  var creditCardSubmit;

  var hostedFieldSetup = function(clientErr, clientInstance) {
    if (clientErr) {
      // Handle error in client creation
      return;
    }

    braintree.hostedFields.create({
      client: clientInstance,
      styles: {
        'input': {
          'font-size': '14px',
          'color': '#555',
          'font-family': 'monospace'
        }
      },
      fields: {
        number: {
          selector: '#card-number',
          placeholder: '4111 1111 1111 1111'
        },
        cvv: {
          selector: '#cvv',
          placeholder: '123'
        },
        expirationDate: {
          selector: '#expiration-date',
          placeholder: '10/2021'
        },
        postalCode: {
          selector: '#postal-code',
          placeholder: '11111'
        }
      }
    }, creditCardFormActions);
  };

  var creditCardFormActions = function (hostedFieldsErr, hostedFieldsInstance) {
    if (hostedFieldsErr) {
      // Handle error in Hosted Fields creation
      return;
    };

    hostedFieldsInstance.on('validityChange', function (event) {
      var validity = event.fields.number.isValid && event.fields.cvv.isValid && event.fields.expirationDate.isValid && event.fields.postalCode.isValid;
      creditCardSubmit.prop('disabled', !validity);
    });

    creditCardSubmit.on('click', function(ev) {
      ev.preventDefault();
      creditCardSubmit.prop('disabled', true)

      hostedFieldsInstance.tokenize(function (tokenizeErr, payload) {
        if (tokenizeErr) {
          // Handle error in Hosted Fields tokenization
          return;
        };

        $('input[name="credit_card_nonce"]').val(payload.nonce)
        $('form#credit-card-form').submit()
      });
    });
  };

  var setupCreditCardtForm = function() {
    braintree.client.create({
      authorization: window.braintreeToken
    }, hostedFieldSetup);
  };

  creditCardSubmit = $('#add-payment-method');

  if (creditCardSubmit.length > 0)
    setupCreditCardtForm();
});
