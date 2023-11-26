import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

import '../../../../provider/auth_provider.dart';
import '../signup/signup_screen.dart';
class SignInScreen extends StatelessWidget {
   SignInScreen({super.key});
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FormBuilder(
        key: _formKey,
        child:
            Container(
              padding: const EdgeInsets.all(16),
              child:

        Column(
          children: [
            Spacer(),
            Text(
              'Sign In',
              style: Theme.of(context).textTheme.headline4,
            ),
            Spacer(),

            FormBuilderTextField(
              name: 'email',
              decoration: const InputDecoration(labelText: 'Email'),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.email(),
              ]),
            ),
            const SizedBox(height: 10),
            FormBuilderTextField(
              name: 'password',
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
              ]),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Forgot Password?',
                style: Theme.of(context).textTheme.bodyText2?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // navigate to forgot password screen
                  },
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                text: 'Don\'t have an account? ',
                style: Theme.of(context).textTheme.bodyText2,
                children: [
                  TextSpan(
                    text: 'Sign Up',
                    style: Theme.of(context).textTheme.bodyText2?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // navigate to sign up screen
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
                      },
                  ),
                ],
              ),
            ),
            Spacer(),
            MaterialButton(
              color: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                // Validate and save the form values
                if(_formKey.currentState!.saveAndValidate()) {
                  debugPrint(_formKey.currentState?.value.toString());
                  String email = _formKey.currentState?.value['email'];
                  String password = _formKey.currentState?.value['password'];

                  context.read<AuthenticationProvider>().signIn(email, password);
                }


              },
              child: context.watch<AuthenticationProvider>().isLoading
                  ?
              Container(
                height: 20,
                width: 20,
                child:
              CircularProgressIndicator(
                color: Colors.white,
              )
              )
                  : const Text(
                'Sign In',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Spacer(),
          ],
        ),
            ),
      ),
    );
  }
}
